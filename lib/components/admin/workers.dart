import 'package:flutter/material.dart';
import 'package:mobilebiydaalt/services/workers_service.dart';
import '../../services/admins_service.dart';
import 'edit_worker.dart';

class WorkersAdmin extends StatefulWidget {
  const WorkersAdmin({super.key});

  @override
  State<WorkersAdmin> createState() => _WorkersAdminState();
}

class _WorkersAdminState extends State<WorkersAdmin> {
  List<dynamic> _workers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await WorkersService.fetchWorkers();
      if (!mounted) return;
      setState(() {
        _workers = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() {
        _workers = [];
        _loading = false;
        _error = msg;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ачааллах үед алдаа: $msg')),
      );
    }
  }

  Widget _avatarFor(dynamic w) {
    final String? imageUrl = (w is Map && w['imageUrl'] != null) ? w['imageUrl'].toString() : null;
    const double size = 40;

    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(radius: size / 2, child: Icon(Icons.person));
    }

    final uri = (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'))
        ? imageUrl
        : '${AdminService.baseUrl}/${imageUrl}'.replaceAll('//', '/').replaceFirst('http:/', 'http://');

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: NetworkImage(uri),
      backgroundColor: Colors.grey[200],
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }

  void _openAddWorker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditWorkerPage(
          worker: null,
          refresh: fetchWorkers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use a Scaffold for all states so the Add button is always accessible.
    return Scaffold(
      appBar: AppBar(title: const Text("Ажилчид")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Алдаа: $_error', textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        ElevatedButton(onPressed: fetchWorkers, child: const Text('Дахин оролдох')),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _openAddWorker,
                          icon: const Icon(Icons.add),
                          label: const Text('Ажилтан нэмэх'),
                        ),
                      ],
                    ),
                  ),
                )
              : _workers.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.group_off, size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('Ажилтан олдсонгүй', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _openAddWorker,
                              icon: const Icon(Icons.add),
                              label: const Text('Ажилтан нэмэх'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(onPressed: fetchWorkers, child: const Text('Дахин ачааллах')),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _workers.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final w = _workers[i];
                        final name = (w is Map && w['name'] != null) ? w['name'].toString() : '—';
                        final phone = (w is Map && w['phone'] != null) ? w['phone'].toString() : '';

                        return ListTile(
                          leading: _avatarFor(w),
                          title: Text(name),
                          subtitle: Text(phone),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditWorkerPage(
                                worker: w,
                                refresh: fetchWorkers,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _openAddWorker,
      ),
    );
  }
}