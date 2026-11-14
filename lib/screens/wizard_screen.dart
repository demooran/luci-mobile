import 'package:flutter/material.dart';
import '../services/rpc_service.dart';
import '../services/wizard_service.dart';

class WizardScreen extends StatefulWidget {
  final RpcService rpcService;
  const WizardScreen({super.key, required this.rpcService});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  late final WizardService _wizard;
  
  String _mode = 'AP';
  String _ip = '192.168.1.21'; // تم التحديث إلى عنوان IP الخاص بك
  String _ssid2g = 'AL-Sarie 2025';
  String _ssid5g = 'AL-Sarie 2025-5G';
  String _ch2g = 'auto';
  String _ch5g = '44';
  String _encryption = 'none';
  bool _isVlan = true;
  String _vlanId = '2025';
  
  bool _loading = true;
  bool _saving = false;

  final Map<String, String> _modesList = {
    'AP': 'برمجة أكسس AP',
    'MESH': 'برمجة مش MESH',
    'WDS_Master': 'برمجة مرسل WDS',
    'WDS_Client': 'برمجة مستقبل WDS',
    'AP_VLAN': 'برمجة أكسس AP + فيلان',
    'MESH_VLAN': 'برمجة مش MESH + فيلان',
    'WDS_Master_VLAN': 'برمجة مرسل WDS + فيلان',
    'WDS_Client_VLAN': 'برمجة مستقبل WDS + فيلان',
    'P2P': 'اكسس بوينت برودباند',
  };

  @override
  void initState() {
    super.initState();
    _wizard = WizardService(widget.rpcService);
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final cfg = await _wizard.getCurrentConfig();
      setState(() {
        _mode = cfg['MKSettings']?.toString() ?? 'AP';
        _ip = cfg['IPADD']?.toString() ?? '192.168.1.21';
        _ssid2g = cfg['SSID2G']?.toString() ?? '';
        _ssid5g = cfg['SSID5G']?.toString() ?? '';
        _ch2g = cfg['CH2G']?.toString() ?? 'auto';
        _ch5g = cfg['CH5G']?.toString() ?? 'auto';
        _encryption = cfg['2WKEYTYPE']?.toString() ?? 'none';
        _isVlan = cfg['mk_is_Vlan']?.toString() == '1';
        _vlanId = cfg['VLANID']?.toString() ?? '1';
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تعذر تحميل الإعدادات: $e')),
        );
      }
    }
  }

  Future<void> _applyConfig() async {
    setState(() => _saving = true);
    try {
      await _wizard.saveConfig(
        mode: _mode,
        ip: _ip,
        ssid2g: _ssid2g,
        ssid5g: _ssid5g,
        ch2g: _ch2g,
        ch5g: _ch5g,
        encryption: _encryption,
        isVlan: _isVlan,
        vlanId: _vlanId,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تطبيق الإعدادات بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: const Text('البرمجة السريعة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _mode,
              decoration: const InputDecoration(labelText: 'وضع البرمجة', border: OutlineInputBorder()),
              items: _modesList.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => setState(() => _mode = v!),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              initialValue: _ip,
              decoration: const InputDecoration(labelText: 'عنوان الـ IP', border: OutlineInputBorder()),
              onChanged: (v) => _ip = v,
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _ssid2g,
              decoration: const InputDecoration(labelText: 'إسم شبكة 2.4G', border: OutlineInputBorder()),
              onChanged: (v) => _ssid2g = v,
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _ssid5g,
              decoration: const InputDecoration(labelText: 'إسم شبكة 5G', border: OutlineInputBorder()),
              onChanged: (v) => _ssid5g = v,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ch2g,
                    decoration: const InputDecoration(labelText: 'قناة 2.4G', border: OutlineInputBorder()),
                    items: ['auto', '1', '6', '11'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _ch2g = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _ch5g,
                    decoration: const InputDecoration(labelText: 'قناة 5G', border: OutlineInputBorder()),
                    items: ['auto', '36', '40', '44', '48', '149', '153', '157', '161'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _ch5g = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _encryption,
              decoration: const InputDecoration(labelText: 'نوع الحماية', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'none', child: Text('مفتوح')),
                DropdownMenuItem(value: 'psk2', child: Text('WPA2-PSK')),
                DropdownMenuItem(value: 'sae', child: Text('WPA3-SAE')),
              ],
              onChanged: (v) => setState(() => _encryption = v!),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text('تفعيل VLAN'),
              value: _isVlan,
              onChanged: (v) => setState(() => _isVlan = v),
            ),

            if (_isVlan)
              TextFormField(
                initialValue: _vlanId,
                decoration: const InputDecoration(labelText: 'رقم VLAN', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onChanged: (v) => _vlanId = v,
              ),
            
            const SizedBox(height: 32),

            FilledButton(
              onPressed: _saving ? null : _applyConfig,
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _saving 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('تطبيق الآن', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
