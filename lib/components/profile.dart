import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFADA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFADA),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.backspace_outlined, color: Colors.orange,),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
            const Text("Хувийн мэдээлэл")
            
          ],
        ),
        automaticallyImplyLeading: false, 
      ),

     body: Column(
      
        children: [
          const SizedBox(height: 20),

          Center(
            child: SizedBox(
              width: 150,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(75),
                child: Image.asset(
                  'images/profile_placeholder.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              children: const [
                SizedBox(height: 20, ),

                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, // 👈 align texts to left
                    children: [
                      const Text("Овог"),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Надмидцэдэн',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),

                      const Text("Нэр"),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'Тэмүүлэн',
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),

                      const Text("Утас"),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: '99999999',
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 10),

                      const Text("Имэйл"),
                      const TextField(
                        decoration: InputDecoration(
                          labelText: 'ex@gmail.com',
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                
              ],
            ),
          ),

          ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(360))),
                    child: const Text('Хадгалах'),
                  ),
        ],
      ),

    );
  }
}