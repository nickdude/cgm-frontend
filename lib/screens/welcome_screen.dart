import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "CGM Health App",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {},
              child: const Text("Login"),
            ),

            const SizedBox(height: 10),

            OutlinedButton(
              onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                    },
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}