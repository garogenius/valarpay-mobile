import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/core/utils/app_messenger.dart';
import 'package:valarpay/features/notifiers/wallet_notifier.dart';
import 'package:valarpay/features/providers/user_provider.dart';
import 'package:valarpay/core/utils/color_utils.dart';
import 'package:valarpay/core/widgets/reusable_transaction_pin_modal.dart';

class PayoutScreen extends ConsumerStatefulWidget {
  final String currency;
  const PayoutScreen({Key? key, required this.currency}) : super(key: key);

  @override
  ConsumerState<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends ConsumerState<PayoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _senderPhoneController = TextEditingController();
  final _senderAddressController = TextEditingController();
  final _routingNumberController = TextEditingController();

  double _payoutFee = 0.0;
  bool _isLoadingFee = false;

  final List<Map<String, String>> _destinationCountries = [
    {'name': 'Nigeria', 'currency': 'NGN', 'flag': '🇳🇬', 'code': 'NG'},
    {'name': 'US Dollar', 'currency': 'USD', 'flag': '🇺🇸', 'code': 'US'},
    {'name': 'Eurozone', 'currency': 'EUR', 'flag': '🇪🇺', 'code': 'EU'},
    {'name': 'United Kingdom', 'currency': 'GBP', 'flag': '🇬🇧', 'code': 'GB'},
    {'name': 'Uganda', 'currency': 'UGX', 'flag': '🇺🇬', 'code': 'UG'},
    {'name': 'Cameroon', 'currency': 'XAF', 'flag': '🇨🇲', 'code': 'CM'},
    {'name': 'Rwanda', 'currency': 'RWF', 'flag': '🇷🇼', 'code': 'RW'},
    {'name': 'Kenya', 'currency': 'KES', 'flag': '🇰🇪', 'code': 'KE'},
    {'name': 'Ghana', 'currency': 'GHS', 'flag': '🇬🇭', 'code': 'GH'},
    {'name': 'Senegal', 'currency': 'XOF', 'flag': '🇸🇳', 'code': 'SN'},
    {'name': 'Tanzania', 'currency': 'TZS', 'flag': '🇹🇿', 'code': 'TZ'},
    {'name': 'Zambia', 'currency': 'ZMW', 'flag': '🇿🇲', 'code': 'ZM'},
    {'name': 'South Africa', 'currency': 'ZAR', 'flag': '🇿🇦', 'code': 'ZA'},
  ];

  Map<String, String>? _selectedCountry;
  String? _destinationCurrency;
  String _destinationCountry = 'NG';

  List<dynamic> _banks = [];
  String? _selectedBankCode;
  String? _accountName;
  bool _isLoadingBanks = true;
  bool _isVerifyingAccount = false;
  bool _isSubmitting = false;

  void _calculateFee(String value) async {
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      setState(() => _payoutFee = 0.0);
      return;
    }

    setState(() => _isLoadingFee = true);
    try {
      final repo = ref.read(walletRepositoryProvider);
      final destCurr = _destinationCurrency ?? widget.currency.toUpperCase();
      final res = await repo.getMultiCurrencyFees(
        currency: destCurr,
        amount: amount,
      );
      if (mounted) {
        setState(() {
          _payoutFee = (res['data']?['fee'] ?? res['fee'] ?? 0.0).toDouble();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _payoutFee = 0.0);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingFee = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Default to wallet currency if it exists in the list, otherwise Nigeria
    try {
      _selectedCountry = _destinationCountries.firstWhere(
        (c) => c['currency'] == widget.currency,
        orElse: () => _destinationCountries.first,
      );
    } catch (_) {
      _selectedCountry = _destinationCountries.first;
    }
    _destinationCurrency = _selectedCountry?['currency'];
    _destinationCountry = _selectedCountry?['code'] ?? 'NG';
    _fetchBanks();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _reasonController.dispose();
    _senderPhoneController.dispose();
    _senderAddressController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchBanks() async {
    try {
      if (_destinationCurrency == null) return;
      final repo = ref.read(walletRepositoryProvider);
      final res = await repo.getPayazaMerchantBanks(_destinationCurrency!);
      if (res['data'] != null && res['data'] is Map && res['data']['data'] is List) {
        setState(() {
          _banks = res['data']['data'];
          _isLoadingBanks = false;
        });
      } else if (res['data'] != null && res['data'] is List) {
        setState(() {
          _banks = res['data'];
          _isLoadingBanks = false;
        });
      } else {
        throw Exception('Invalid banks payload');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBanks = false);
        AppMessenger.show(context, message: 'Failed to load banks: $e', type: MessageType.error);
      }
    }
  }

  Future<void> _verifyAccount() async {
    final acct = _accountNumberController.text.trim();
    if (acct.length < 5 || _selectedBankCode == null) return;

    setState(() {
      _isVerifyingAccount = true;
      _accountName = null;
    });

    try {
      final repo = ref.read(walletRepositoryProvider);
      final res = await repo.verifyPayazaAccount(
        accountNumber: acct,
        bankCode: _selectedBankCode!,
        currency: _destinationCurrency ?? widget.currency,
      );
      final data = res['data'] ?? res;
      String? verifiedName = data['accountName'] ?? data['account_name'] ?? data['name'];
      
      if (verifiedName == null && res['response_content'] != null) {
        verifiedName = res['response_content']['account_name'] ?? res['response_content']['accountName'];
      } else if (verifiedName == null && data['response_content'] != null) {
        verifiedName = data['response_content']['account_name'] ?? data['response_content']['accountName'];
      }

      if (verifiedName != null) {
        setState(() {
          _accountName = verifiedName!.toString();
        });
      } else {
        throw Exception('Account name not found in response');
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(context, message: 'Account verification failed', type: MessageType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifyingAccount = false);
      }
    }
  }

  Future<void> _submitPayout(String pinStr) async {
    if (!_formKey.currentState!.validate()) return;
    if (_accountName == null) {
      AppMessenger.show(context, message: 'Please wait for account verification', type: MessageType.error);
      return;
    }

    final user = ref.read(userProvider);
    final wallet = user?.wallets.firstWhere((w) => w.currency.toUpperCase() == widget.currency.toUpperCase(), orElse: () => null as dynamic);
    
    if (wallet == null) {
      AppMessenger.show(context, message: 'Wallet not found', type: MessageType.error);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(walletRepositoryProvider);
      final amount = double.parse(_amountController.text);
      final reason = _reasonController.text.trim().isEmpty ? 'Payout' : _reasonController.text.trim();
      
      final destCurr = _destinationCurrency ?? widget.currency.toUpperCase();
      final isPayshiga = destCurr != 'NGN';
      
      if (isPayshiga) {
        await repo.createPayshigaPayout(
          sourceWalletId: wallet.id,
          amount: amount,
          currency: destCurr,
          bankCode: _selectedBankCode!,
          accountNumber: _accountNumberController.text.trim(),
          accountName: _accountName!,
          narration: reason,
          reference: 'PAYOUT-${DateTime.now().millisecondsSinceEpoch}',
          accountType: destCurr == 'USD' ? 'ACH' : null,
          routingNumber: destCurr == 'USD' ? _routingNumberController.text.trim() : null,
        );
      } else {
        await repo.createPayazaPayout(
          sourceWalletId: wallet.id,
          amount: amount,
          currency: destCurr,
          destinationCountry: _getCountryCodeFromCurrency(destCurr),
          accountReference: 'PAYOUT-${DateTime.now().millisecondsSinceEpoch}',
          bankCode: _selectedBankCode!,
          accountNumber: _accountNumberController.text.trim(),
          accountName: _accountName!,
          transactionType: 'nuban',
          transactionPin: int.tryParse(pinStr) ?? 0,
          reason: reason,
          senderPhone: _senderPhoneController.text.trim().isEmpty ? '0000000000' : _senderPhoneController.text.trim(),
          senderAddress: _senderAddressController.text.trim().isEmpty ? 'N/A' : _senderAddressController.text.trim(),
        );
      }

      if (mounted) {
        AppMessenger.show(context, message: 'Payout initiated successfully!', type: MessageType.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        AppMessenger.show(context, message: e.toString(), type: MessageType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _getCountryCodeFromCurrency(String currencyCode) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN': return 'NG';
      case 'GHS': return 'GH';
      case 'KES': return 'KE';
      case 'UGX': return 'UG';
      case 'XAF': return 'CM';
      case 'USD': return 'US';
      case 'GBP': return 'GB';
      case 'EUR': return 'EU';
      case 'ZAR': return 'ZA';
      case 'RWF': return 'RW';
      case 'TZS': return 'TZ';
      case 'ZMW': return 'ZM';
      case 'XOF': return 'SN';
      default: return 'NG';
    }
  }

  String _getCountryNameFromCurrency(String currencyCode, String currencyName) {
    switch (currencyCode.toUpperCase()) {
      case 'NGN': return 'Nigeria';
      case 'USD': return 'United States';
      case 'EUR': return 'Eurozone';
      case 'GBP': return 'United Kingdom';
      case 'UGX': return 'Uganda';
      case 'XAF': return 'Cameroon';
      case 'RWF': return 'Rwanda';
      case 'KES': return 'Kenya';
      case 'GHS': return 'Ghana';
      case 'XOF': return 'Senegal';
      case 'TZS': return 'Tanzania';
      case 'ZMW': return 'Zambia';
      case 'ZAR': return 'South Africa';
      default: return currencyName;
    }
  }

  void _showCountrySelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Destination', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _destinationCountries.length,
                  itemBuilder: (context, index) {
                    final country = _destinationCountries[index];
                    return ListTile(
                      leading: Text(country['flag']!, style: const TextStyle(fontSize: 24)),
                      title: Text(country['name']!),
                      subtitle: Text(country['currency']!),
                      trailing: _selectedCountry?['currency'] == country['currency'] ? Icon(Icons.check, color: appTheme.primaryColor) : null,
                      onTap: () {
                        setState(() {
                          _selectedCountry = country;
                          _destinationCurrency = country['currency'];
                          _destinationCountry = country['code'] ?? 'NG';
                          _selectedBankCode = null;
                          _accountName = null;
                          _accountNumberController.clear();
                          _isLoadingBanks = true;
                          _banks = [];
                        });
                        Navigator.pop(context);
                        _fetchBanks();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBankSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Select Bank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: _banks.length,
                  itemBuilder: (context, index) {
                    final b = _banks[index];
                    final code = (b['code'] ?? b['bankCode'])?.toString();
                    final name = (b['name'] ?? b['bankName'] ?? 'Unknown Bank').toString();
                    final avatarUrl = b['avatar']?.toString();
                    return ListTile(
                      leading: avatarUrl != null && avatarUrl.isNotEmpty
                          ? Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey.withOpacity(0.1),
                                image: DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : CircleAvatar(
                              backgroundColor: appTheme.primaryColor.withOpacity(0.1),
                              child: Icon(Icons.account_balance, color: appTheme.primaryColor),
                            ),
                      title: Text(name),
                      trailing: _selectedBankCode == code ? Icon(Icons.check, color: appTheme.primaryColor) : null,
                      onTap: () {
                        setState(() => _selectedBankCode = code);
                        Navigator.pop(context);
                        _verifyAccount();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currency.toUpperCase()} Payout'),
        elevation: 0,
      ),
      body: _isLoadingBanks 
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Send money directly to a local bank account.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              GestureDetector(
                onTap: _showCountrySelectionModal,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Destination Country',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedCountry != null) ...[
                        Row(
                          children: [
                            Text(_selectedCountry!['flag']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text('${_selectedCountry!['name']} (${_selectedCountry!['currency']})', style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ] else ...[
                        const Text('Select Destination', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ],
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: _showBankSelectionModal,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Select Bank',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    errorText: (_selectedBankCode == null && _formKey.currentState?.validate() == false) ? 'Please select a bank' : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_selectedBankCode != null && _banks.isNotEmpty) ...[
                        Builder(
                          builder: (context) {
                            final selectedBank = _banks.firstWhere((b) => (b['code'] ?? b['bankCode'])?.toString() == _selectedBankCode, orElse: () => null);
                            final avatarUrl = selectedBank?['avatar']?.toString();
                            if (avatarUrl != null && avatarUrl.isNotEmpty) {
                              return Container(
                                width: 24,
                                height: 24,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(avatarUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }
                            return Container(
                              width: 24,
                              height: 24,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(shape: BoxShape.circle, color: appTheme.primaryColor.withOpacity(0.1)),
                              child: Icon(Icons.account_balance, size: 14, color: appTheme.primaryColor),
                            );
                          },
                        ),
                      ],
                      Expanded(
                        child: Text(
                          _selectedBankCode == null 
                              ? 'Choose a bank' 
                              : (_banks.firstWhere((b) => (b['code'] ?? b['bankCode'])?.toString() == _selectedBankCode, orElse: () => {'name': 'Unknown'})['name'] ?? _banks.firstWhere((b) => (b['code'] ?? b['bankCode'])?.toString() == _selectedBankCode, orElse: () => {'bankName': 'Unknown'})['bankName']).toString(),
                          style: TextStyle(color: _selectedBankCode == null ? Colors.grey : null),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _accountNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: _isVerifyingAccount 
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ) 
                    : TextButton(
                        onPressed: _verifyAccount,
                        child: const Text('Verify'),
                      ),
                ),
                onChanged: (val) {
                  if (val.length == 10) _verifyAccount();
                },
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              
              if (_accountName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _accountName!,
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '${widget.currency.toUpperCase()} ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (val) {
                  _calculateFee(val);
                },
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null || double.parse(val) <= 0) return 'Invalid amount';
                  return null;
                },
              ),
              if (_isLoadingFee) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text('Calculating fee...', style: TextStyle(color: Colors.grey, fontSize: 12)),
                )
              ] else if (_payoutFee > 0) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                  child: Text('Transaction Fee: ${widget.currency.toUpperCase()} ${_payoutFee.toStringAsFixed(2)}', style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Narration / Reason (Optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              
              if (_destinationCurrency == 'USD') ...[
                TextFormField(
                  controller: _routingNumberController,
                  decoration: InputDecoration(
                    labelText: 'Routing Number (ACH)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required for USD payout' : null,
                ),
                const SizedBox(height: 16),
              ],
              
              TextFormField(
                controller: _senderPhoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Sender Phone Number',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required for payout' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _senderAddressController,
                decoration: InputDecoration(
                  labelText: 'Sender Address',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required for payout' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSubmitting 
                    ? null 
                    : () {
                        if (!_formKey.currentState!.validate()) return;
                        if (_accountName == null) {
                          AppMessenger.show(context, message: 'Please wait for account verification', type: MessageType.error);
                          return;
                        }
                        
                        final amount = double.parse(_amountController.text);
                        final total = amount + _payoutFee;

                        TransactionPinModal.show(
                          context,
                          title: 'Enter Transaction PIN',
                          subtitle: 'Total to be debited: ${widget.currency.toUpperCase()} ${total.toStringAsFixed(2)}',
                          onCompletePin: (pin) {
                            Navigator.pop(context); // close modal
                            _submitPayout(pin);
                          },
                        );
                      },
                  child: _isSubmitting 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Payout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
