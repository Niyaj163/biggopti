import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class EligibilityScreen extends StatefulWidget {
  const EligibilityScreen({super.key});

  @override
  State<EligibilityScreen> createState() => _EligibilityScreenState();
}

class _EligibilityScreenState extends State<EligibilityScreen> {
  final _formKey = GlobalKey<FormState>();
  int _age = 24;
  String _degree = 'bachelor';
  bool _isQuota = false;
  bool _hasChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('আপনার আবেদন যোগ্যতা পরীক্ষা'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Card
            Card(
              color: AppColors.primary,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.verified_user_rounded,
                        size: 36, color: AppColors.secondary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'আপনি কি যোগ্য?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'আপনার বয়স ও ডিগ্রী দিয়ে সব সার্কুলারের যোগ্যতা মেলাুন।',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Form
            Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('আপনার বয়স (বছর):',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: '$_age',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'যেমন: ২৩',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _age = int.tryParse(val) ?? 24;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    const Text('সর্বোচ্চ শিক্ষাগত যোগ্যতা:',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _degree,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'hsc', child: Text('এইচএসসি (HSC)')),
                        DropdownMenuItem(
                            value: 'bachelor', child: Text('স্নাতক/অনার্স (Bachelor)')),
                        DropdownMenuItem(
                            value: 'masters', child: Text('স্নাতকোত্তর (Masters)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _degree = val);
                      },
                    ),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      activeThumbColor: AppColors.primary,
                      title: const Text('মুক্তিযোদ্ধা / অন্যান্য কোটা আছে?',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      value: _isQuota,
                      onChanged: (val) => setState(() => _isQuota = val),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _hasChecked = true;
                          });
                        },
                        child: const Text('যোগ্যতা যাচাই করুন'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_hasChecked) ...[
              const SizedBox(height: 24),
              const Text(
                'যাচাইকৃত ফলাফল:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _age <= (_isQuota ? 32 : 30)
                                ? 'আপনি সাম্প্রতিক বিসিএস ও ব্যাংক সার্কুলারে আবেদনযোগ্য!'
                                : 'সাধারণ কোটায় বয়সসীমা অতিক্রান্ত, তবে অভিজ্ঞ পদের জন্য প্রযোজ্য।',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
