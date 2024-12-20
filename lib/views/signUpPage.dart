import 'package:flutter/material.dart';
import 'package:hedieaty_app/controllers/user_controller.dart';

class SignupPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController= TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();
  final TextEditingController _preferencesController = TextEditingController();

  final UserController _userController = UserController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _mobileController,
                decoration: InputDecoration(
                  labelText: 'mobile',
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value == null || value.length<11){
                    return 'Please write correct mobile number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16,),

              // Password Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Re-enter Password Field
              TextFormField(
                controller: _repasswordController,
                decoration: InputDecoration(
                  labelText: 'Re-enter Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Preferences Field
              TextFormField(
                controller: _preferencesController,
                decoration: InputDecoration(
                  labelText: 'Preferences (e.g., Books, Music)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Sign Up Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final user = await _userController.signUpUser(
                        name: _nameController.text,
                        email: _emailController.text,
                        mobile: _mobileController.text,
                        password: _passwordController.text,
                        repassword: _repasswordController.text,
                        preferences: {
                          'categories': _preferencesController.text
                              .split(',')
                              .map((e) => e.trim())
                              .toList(),
                        },
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User signed up: ${user.name}')),
                      );
                    } catch (e) {
                      print("ccccccccccccccccccccccccccccccccc");
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
