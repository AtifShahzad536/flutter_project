import 'package:flutter/material.dart';
import 'package:export_trix/data/services/api_service.dart';
import 'package:export_trix/core/utils/logger.dart';

class RiderProfileScreen extends StatefulWidget {
  const RiderProfileScreen({super.key});

  @override
  State<RiderProfileScreen> createState() => _RiderProfileScreenState();
}

class _RiderProfileScreenState extends State<RiderProfileScreen> {
  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bikeModelController = TextEditingController();
  final _bikePlateController = TextEditingController();
  final _cnicController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final data = await ApiService.getProfile();
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        // These might be in business_profile or similar, check API
        _bikeModelController.text = data['bike_model'] ?? 'Not Set';
        _bikePlateController.text = data['number_plate'] ?? 'Not Set';
        _cnicController.text = data['cnic'] ?? 'Not Set';
        _isLoading = false;
      });
    } catch (e) {
      AppLogger.error('Error fetching user profile', e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 800) {
          return _buildDesktopLayout();
        } else {
          return _buildMobileLayout();
        }
      },
    );
  }

  // --- Desktop Layout ---
  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column: User Profile Card (Fixed Width)
          SizedBox(
            width: 350,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF3B82F6)
                                  .withValues(alpha: 0.2),
                              width: 3),
                        ),
                        child: const CircleAvatar(
                          radius: 60,
                          backgroundColor: Color(0xFFEFF6FF),
                          backgroundImage: NetworkImage(
                              'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                      _nameController.text.isEmpty
                          ? "User"
                          : _nameController.text,
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B))),
                  const Text("Rider",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 32),

                  // Stats in Profile (Optional)
                  _buildProfileStatRow(
                      Icons.check_circle_outline, "1,240", "Total Deliveries"),
                  const SizedBox(height: 16),
                  _buildProfileStatRow(
                      Icons.star_border, "4.9", "Average Rating"),
                  const SizedBox(height: 16),
                  _buildProfileStatRow(
                      Icons.calendar_today, "2 Years", "Member Since"),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        // Change Password
                      },
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12))),
                      child: const Text("Change Password",
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 32),

          // Right Column: Edit Details Form
          Flexible(
            child: Container(
              constraints: const BoxConstraints(minHeight: 600),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Account Details",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B))),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isEditing = !_isEditing);
                          if (!_isEditing) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Profile Updated Successfully!')),
                            );
                          }
                        },
                        icon: Icon(_isEditing ? Icons.save : Icons.edit,
                            size: 18),
                        label:
                            Text(_isEditing ? "Save Changes" : "Edit Profile"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _isEditing
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E3A8A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12))),
                      )
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Grid Form
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildTextField("Full Name", _nameController,
                              Icons.person_outline)),
                      const SizedBox(width: 24),
                      Expanded(
                          child: _buildTextField("Phone Number",
                              _phoneController, Icons.phone_android)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildTextField("CNIC Number", _cnicController,
                              Icons.badge_outlined)),
                      const SizedBox(width: 24),
                      Expanded(
                          child:
                              Container()), // Spacer for symmetry if odd fields
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Vehicle Header
                  const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Vehicle Information",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B)))),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildTextField(
                          "Bike Model",
                          _bikeModelController,
                          Icons.motorcycle_rounded,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildTextField(
                          "Number Plate",
                          _bikePlateController,
                          Icons.confirmation_number_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStatRow(IconData icon, String value, String label) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1E293B))),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

  // --- Mobile Layout ---
  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Hero Header for Profile
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 40, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        backgroundImage: NetworkImage(
                            'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981), // Green
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _nameController.text.isEmpty ? "User" : _nameController.text,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Rider",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Personal Info Section
                _buildSectionHeader("Personal Information"),
                _buildTextField(
                    "Full Name", _nameController, Icons.person_outline_rounded),
                _buildTextField("Phone Number", _phoneController,
                    Icons.phone_android_rounded),
                _buildTextField(
                    "CNIC Number", _cnicController, Icons.badge_outlined),
                const SizedBox(height: 24),

                // Bike Details Section
                _buildSectionHeader("Vehicle Details"),
                Row(
                  children: [
                    Expanded(
                        child: _buildTextField("Bike Model",
                            _bikeModelController, Icons.motorcycle_rounded)),
                    const SizedBox(width: 16),
                    Expanded(
                        child: _buildTextField(
                            "Number Plate",
                            _bikePlateController,
                            Icons.confirmation_number_outlined)),
                  ],
                ),
                const SizedBox(height: 32),

                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _isEditing = !_isEditing);
                      if (!_isEditing) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Profile Updated Successfully!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _isEditing
                            ? const Color(0xFF10B981)
                            : const Color(0xFF1E40AF),
                        elevation: 5,
                        shadowColor: (_isEditing
                                ? const Color(0xFF10B981)
                                : const Color(0xFF1E40AF))
                            .withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: Text(
                      _isEditing ? "Save Changes" : "Edit Profile",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: TextButton(
                    onPressed: () {
                      // Change Password Logic
                    },
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    child: const Text("Change Password",
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Color(0xFF9CA3AF)), // Gray 400
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ],
                border: Border.all(color: Colors.grey.shade200)),
            child: TextField(
              controller: controller,
              enabled: _isEditing,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.grey),
                prefixIcon: Icon(icon, color: const Color(0xFF3B82F6)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
                filled: true,
                fillColor: _isEditing
                    ? Colors.blue.withValues(alpha: 0.05)
                    : Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
