import 'rpc_service.dart';

class WizardService {
  final RpcService rpc;
  WizardService(this.rpc);

  // جلب الإعدادات من القسم 'default'
  Future<Map<String, dynamic>> getCurrentConfig() async {
    try {
      final result = await rpc.call('uci', 'get', {
        'config': 'wizard',
        'section': 'default',
      });
      return Map<String, dynamic>.from(result);
    } catch (e) {
      throw Exception('فشل جلب الإعدادات: $e');
    }
  }

  // حفظ الإعدادات باستخدام الأسماء الصحيحة
  Future<void> saveConfig({
    required String mode,
    required String ip,
    required String ssid2g,
    required String ssid5g,
    required String ch2g,
    required String ch5g,
    required String encryption,
    required bool isVlan,
    required String vlanId,
  }) async {
    try {
      final values = {
        'enabled': '1',
        'MKSettings': mode,
        'IPADD': ip,
        'NETMASK': '255.255.255.0',
        'mk_is_Vlan': isVlan ? '1' : '0',
        'VLANID': vlanId,
        'SSID2G': ssid2g,
        'CH2G': ch2g,
        '2WKEYTYPE': encryption,
        'SSID5G': ssid5g,
        'CH5G': ch5g,
        '5WKEYTYPE': encryption, // نفترض نفس نوع الحماية للشبكتين
        'CHWidte': 'auto',
      };

      // 1. كتابة القيم
      await rpc.call('uci', 'set', {
        'config': 'wizard',
        'section': 'default',
        'values': values,
      });
      
      // 2. تثبيت التغييرات
      await rpc.call('uci', 'commit', {
        'config': 'wizard',
      });
      
      // 3. تشغيل السكربت لتطبيق التغييرات على الشبكة
      await rpc.call('file', 'exec', {
        'command': '/etc/init.d/wizard',
        'params': ['reload'],
      });
    } catch (e) {
      throw Exception('فشل حفظ الإعدادات: $e');
    }
  }
}
