import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';

enum DetailKind { order, store }

class Items extends StatefulWidget {
  final DetailKind kind;
  final String title;
  final String? imagePath;
  final Widget? imageWidget;
  final String? shopId;

  const Items({
    super.key,
    required this.kind,
    required this.title,
    this.imagePath,
    this.imageWidget,
    this.shopId,
  });

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {
  late List<Product> _products = [];
  final Map<int, int> _selected = {};
  bool _loading = true;

  static const double _bottomBarHeight = 64.0;

  int get _total {
    int sum = 0;
    _selected.forEach((index, qty) {
      if (index >= 0 && index < _products.length) {
        sum += _products[index].price * qty;
      }
    });
    return sum;
  }

  @override
  void initState() {
    super.initState();
    if (widget.shopId != null) {
      _fetchProducts(widget.shopId!);
    } else {
      _loading = false;
    }
  }
  final String baseUrl = 'http://localhost:5000';


  Future<void> _fetchProducts(String shopId) async {
    try {
      final url = '$baseUrl/shops/$shopId/products'; // use baseUrl
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _products = data.map((item) => Product.fromJson(item)).toList();
          _loading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _increment(int index) {
    setState(() {
      final selectedQty = _selected[index] ?? 0;
      if (selectedQty < _products[index].quantity) {
        _selected[index] = selectedQty + 1;
      }
    });
  }

  void _decrement(int index) {
    setState(() {
      final selectedQty = _selected[index] ?? 0;
      if (selectedQty > 0) {
        _selected[index] = selectedQty - 1;
        if (_selected[index] == 0) _selected.remove(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isOrder = widget.kind == DetailKind.order;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: isOrder ? Colors.orange : Colors.deepPurple,
      ),
      body: _products.isEmpty
          ? const Center(child: Text("No products available"))
          : Column(
              children: [
                if (widget.imageWidget != null || widget.imagePath != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: widget.imageWidget ??
                          (widget.imagePath != null
                              ? Image.asset(widget.imagePath!,
                                  height: 160, fit: BoxFit.cover)
                              : const SizedBox.shrink()),
                    ),
                  ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(
                        top: 12, left: 12, right: 12, bottom: _bottomBarHeight + 12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, idx) {
                      final p = _products[idx];
                      final qty = _selected[idx] ?? 0;
                      final selected = qty > 0;

                      return GestureDetector(
                        onTap: () => _increment(idx),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 6,
                                offset: const Offset(2, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 5,
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child: Image.network(
                                    p.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) =>
                                        Container(color: Colors.grey.shade200),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  p.name,
                                  style: const TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${p.price}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: selected ? Colors.orange : Colors.black87,
                                            ),
                                          ),
                                          if (selected)
                                            TextSpan(
                                              text: ' × $qty',
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black54),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Text('Бэлэн: ${p.quantity}',
                                        style: const TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                              if (selected)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: SizedBox(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          onPressed: () => _decrement(idx),
                                          icon: const Icon(Icons.remove_circle_outline,
                                              color: Colors.redAccent),
                                        ),
                                        Text('$qty',
                                            style: const TextStyle(fontWeight: FontWeight.bold)),
                                        IconButton(
                                          onPressed: () => _increment(idx),
                                          icon: const Icon(Icons.add_circle_outline,
                                              color: Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        height: _bottomBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                        text: 'Нийт тооцоо  ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.orange)),
                    TextSpan(
                        text: '$_total мт',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
              ),
            ),
            IconButton(
              onPressed: _total > 0
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Proceeding with total $_total мт')));
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
