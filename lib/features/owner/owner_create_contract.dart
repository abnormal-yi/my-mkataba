import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_mkataba/core/theme/app_theme.dart';
import 'package:my_mkataba/providers/contract_provider.dart';
import 'package:my_mkataba/widgets/common_widgets.dart';

class OwnerCreateContract extends ConsumerStatefulWidget {
  const OwnerCreateContract({super.key});

  @override
  ConsumerState<OwnerCreateContract> createState() => _OwnerCreateContractState();
}

class _OwnerCreateContractState extends ConsumerState<OwnerCreateContract> {
  final _formKey = GlobalKey<FormState>();
  final _driverNameC = TextEditingController();
  final _phoneC = TextEditingController();
  final _plateC = TextEditingController();
  final _vehicleTypeC = TextEditingController();
  final _dailyTargetC = TextEditingController();
  final _paymentDayC = TextEditingController();
  final _termsC = TextEditingController();

  @override
  void dispose() {
    _driverNameC.dispose();
    _phoneC.dispose();
    _plateC.dispose();
    _vehicleTypeC.dispose();
    _dailyTargetC.dispose();
    _paymentDayC.dispose();
    _termsC.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final data = {
      'rider_name': _driverNameC.text,
      'phone': _phoneC.text,
      'plate_number': _plateC.text,
      'vehicle_type': _vehicleTypeC.text,
      'daily_target': double.parse(_dailyTargetC.text),
      'notes': _termsC.text,
    };
    await ref.read(contractProvider.notifier).create(data);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contract created successfully')),
      );
      context.go('/owner');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.accent,
        elevation: 0,
        title: const Text('New Contract', style: TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ScreenCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('DRIVER DETAILS'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _driverNameC,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      decoration: InputDecoration(
                        labelText: 'Driver Name',
                        prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.muted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.muted),
                        prefixText: '+255 ',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ScreenCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('VEHICLE INFO'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _plateC,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Plate',
                        prefixIcon: const Icon(Icons.directions_car_outlined, size: 20, color: AppColors.muted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _vehicleTypeC,
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                      decoration: InputDecoration(
                        labelText: 'Vehicle Type',
                        hintText: 'Bajaj, Boxer, TVS...',
                        prefixIcon: const Icon(Icons.motorcycle_outlined, size: 20, color: AppColors.muted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ScreenCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('PAYMENT TERMS'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dailyTargetC,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Daily Target (TSh)',
                        prefixIcon: const Icon(Icons.monetization_on_outlined, size: 20, color: AppColors.muted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _paymentDayC,
                      decoration: InputDecoration(
                        labelText: 'Payment Day',
                        hintText: 'End of month',
                        prefixIcon: const Icon(Icons.calendar_today_outlined, size: 20, color: AppColors.muted),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _termsC,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Contract Terms',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(top: 14),
                          child: Icon(Icons.description_outlined, size: 20, color: AppColors.muted),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.inputBorder)),
                        filled: true, fillColor: AppColors.bg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  label: const Text('Create Contract', style: TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
