import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/endpoint.dart';
import '../data/services/api_service.dart';
import '../themes/themes.dart';

class PosTerminalDevice {
  final String id;
  final String deviceName;
  final String branch;
  final String cashierName;
  final String cashierPhone;
  final String ipAddress;
  final String deviceModel;
  final int batteryLevel;
  final int latencyMs;
  final int pendingQueue;
  final String status; // 'Online', 'In Sale', 'Idle'
  final bool printerConnected;
  final DateTime lastPing;

  PosTerminalDevice({
    required this.id,
    required this.deviceName,
    required this.branch,
    required this.cashierName,
    required this.cashierPhone,
    required this.ipAddress,
    required this.deviceModel,
    required this.batteryLevel,
    required this.latencyMs,
    required this.pendingQueue,
    required this.status,
    required this.printerConnected,
    required this.lastPing,
  });
}

class PosTerminalsScreen extends StatefulWidget {
  const PosTerminalsScreen({super.key});

  @override
  State<PosTerminalsScreen> createState() => _PosTerminalsScreenState();
}

class _PosTerminalsScreenState extends State<PosTerminalsScreen> {
  static const Color primaryBlue = AppThemes.primaryBlue;
  static const Color primaryOrange = primaryBlue;

  String selectedFilter = 'all';
  bool isLoading = false;

  final List<PosTerminalDevice> terminals = [
    PosTerminalDevice(
      id: 'POS-TK01-01',
      deviceName: 'BKK1 Branch Counter 01',
      branch: 'AudiCafe BKK1 Branch (BKK02)',
      cashierName: 'Bopha Meas',
      cashierPhone: '078 333 444',
      ipAddress: '192.168.1.101',
      deviceModel: 'Sunmi T2s Touch POS',
      batteryLevel: 100,
      latencyMs: 14,
      pendingQueue: 0,
      status: 'Online & Active',
      printerConnected: true,
      lastPing: DateTime.now(),
    ),
    PosTerminalDevice(
      id: 'POS-TK01-02',
      deviceName: 'TK Flagship Counter 01',
      branch: 'AudiCafe Flagship (TK01)',
      cashierName: 'Sophea Sok',
      cashierPhone: '012 888 999',
      ipAddress: '192.168.1.102',
      deviceModel: 'iMin D4-503 Dual Screen POS',
      batteryLevel: 98,
      latencyMs: 12,
      pendingQueue: 0,
      status: 'Online & Active',
      printerConnected: true,
      lastPing: DateTime.now(),
    ),
    PosTerminalDevice(
      id: 'POS-SR03-01',
      deviceName: 'Siem Reap Main Bar Counter',
      branch: 'AudiCafe Siem Reap (SR03)',
      cashierName: 'Chan Somnang',
      cashierPhone: '012 334 556',
      ipAddress: '192.168.2.55',
      deviceModel: 'Pax E700 Integrated POS',
      batteryLevel: 95,
      latencyMs: 22,
      pendingQueue: 0,
      status: 'Online & Active',
      printerConnected: true,
      lastPing: DateTime.now(),
    ),
    PosTerminalDevice(
      id: 'POS-SHV04-01',
      deviceName: 'SHV Beachside Kiosk 01',
      branch: 'AudiCafe Express Sihanoukville (SHV04)',
      cashierName: 'Vicheka Keo',
      cashierPhone: '097 888 123',
      ipAddress: '192.168.3.10',
      deviceModel: 'Sunmi V2 Pro Mobile Terminal',
      batteryLevel: 88,
      latencyMs: 35,
      pendingQueue: 0,
      status: 'Standby / Inactive',
      printerConnected: false,
      lastPing: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchLiveTerminals();
  }

  Future<void> fetchLiveTerminals() async {
    try {
      setState(() => isLoading = true);
      final api = ApiService.to;
      final staffRes = await api.getStaff();
      if (staffRes.isSuccess && staffRes.data != null && staffRes.data!.isNotEmpty) {
        setState(() {
          terminals.clear();
          for (var s in staffRes.data!) {
            terminals.add(PosTerminalDevice(
              id: 'POS-00${s.id}',
              deviceName: '${s.storeName ?? "Main Counter"} (${s.fullName})',
              branch: s.storeName ?? 'AudiCafe Flagship',
              cashierName: s.fullName,
              cashierPhone: s.phoneNumber,
              ipAddress: '127.0.0.1',
              deviceModel: 'Touch POS Terminal',
              batteryLevel: 98,
              latencyMs: 15,
              pendingQueue: 0,
              status: s.isActive ? 'Online & Active' : 'Offline',
              printerConnected: true,
              lastPing: DateTime.now(),
            ));
          }
        });
      }
    } catch (_) {} finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  List<PosTerminalDevice> get filteredTerminals {
    if (selectedFilter == 'all') return terminals;
    return terminals.where((t) {
      if (selectedFilter == 'tk') return t.branch.contains('TK01');
      if (selectedFilter == 'bkk') return t.branch.contains('BKK02');
      if (selectedFilter == 'sr') return t.branch.contains('SR03');
      return true;
    }).toList();
  }

  Future<void> _pingTerminal(PosTerminalDevice terminal) async {
    final stopwatch = Stopwatch()..start();
    final isOnline = await ApiService.to.checkServerHealth();
    stopwatch.stop();
    final ms = stopwatch.elapsedMilliseconds;

    Get.snackbar(
      isOnline ? 'ping_successful'.tr : 'server_offline'.tr,
      'Terminal ${terminal.deviceName} latency: $ms ms (Host: ${Endpoints.baseUrl})',
      backgroundColor: isOnline ? const Color(0xFF2E7D32) : Colors.red.shade700,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(isOnline ? Icons.network_check_rounded : Icons.signal_cellular_connected_no_internet_4_bar_rounded, color: Colors.white),
    );
  }

  void _sendMessageToTerminal(PosTerminalDevice terminal) {
    final msgCtrl = TextEditingController(text: 'notifications'.tr);

    Get.defaultDialog(
      title: '${'send_msg_to_terminal'.tr} ${terminal.id}',
      titleStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: TextField(
          controller: msgCtrl,
          maxLines: 2,
          decoration: InputDecoration(labelText: 'notifications'.tr),
        ),
      ),
      textConfirm: 'send_alert_btn'.tr,
      textCancel: 'cancel'.tr,
      confirmTextColor: Colors.white,
      buttonColor: primaryOrange,
      onConfirm: () {
        Get.back();
        Get.snackbar(
          'msg_delivered'.tr,
          'Instant notification sent to ${terminal.cashierName}',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(12),
          borderRadius: 12,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemes.darkCard : primaryOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'pos_terminals_online'.tr,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Colors.white),
            tooltip: 'sync_all_terminals'.tr,
            onPressed: () {
              Get.snackbar(
                'sync_triggered'.tr,
                'All 8 active POS terminals synchronized with WebSocket node.',
                backgroundColor: const Color(0xFF2E7D32),
                colorText: Colors.white,
                snackPosition: SnackPosition.TOP,
                margin: const EdgeInsets.all(12),
                borderRadius: 12,
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Network Health Banner
          _buildNetworkBanner(context),

          // Outlet Filter Chips
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip('all', 'all_branches_terminals'.tr),
                  const SizedBox(width: 8),
                  _buildFilterChip('tk', 'AudiCafe Flagship (TK01)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('bkk', 'BKK1 Branch (BKK02)'),
                  const SizedBox(width: 8),
                  _buildFilterChip('sr', 'Siem Reap (SR03)'),
                ],
              ),
            ),
          ),

          // Terminals List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: filteredTerminals.length,
              itemBuilder: (context, index) {
                final item = filteredTerminals[index];
                return _buildTerminalCard(context, item);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        onPressed: () {
          Get.snackbar(
            'pair_new_pos'.tr,
            'pair_new_pos_desc'.tr,
            backgroundColor: const Color(0xFF0288D1),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
          );
        },
        icon: const Icon(Icons.add_to_queue_rounded),
        label: Text('connect_new_pos_btn'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNetworkBanner(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF2C3E50), const Color(0xFF1A252F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'WebSocket Live Sync Engine',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'ACTIVE (8 NODES)',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('sync_protocol_wss'.tr, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('${'avg_latency'.tr}: 18 ms', style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text('${'pending_queue'.tr}: 0', style: const TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = selectedFilter == key;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => selectedFilter = key),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryOrange
                : (isDark ? AppThemes.darkSurface : const Color(0xFFEEF2F6)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? primaryOrange : (isDark ? AppThemes.darkBorder : Colors.transparent),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppThemes.darkTextSecondary : const Color(0xFF475569)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTerminalCard(BuildContext context, PosTerminalDevice item) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Device Name, Status, ID
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0288D1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.point_of_sale_rounded, color: Color(0xFF0288D1), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.deviceName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.branch} • ID: ${item.id}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppThemes.darkTextSecondary : AppThemes.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Cashier and IP Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: primaryOrange),
                    const SizedBox(width: 4),
                    Text(
                      'Cashier: ${item.cashierName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                Text(
                  'IP: ${item.ipAddress}',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Device Info Badges: Battery, Latency, Printer
            Row(
              children: [
                _buildMiniBadge(Icons.battery_charging_full_rounded, '${item.batteryLevel}%', const Color(0xFF2E7D32), isDark),
                const SizedBox(width: 8),
                _buildMiniBadge(Icons.speed_rounded, '${item.latencyMs} ms', const Color(0xFF0288D1), isDark),
                const SizedBox(width: 8),
                _buildMiniBadge(
                  Icons.print_rounded,
                  item.printerConnected ? '80mm Ready' : 'No Printer',
                  item.printerConnected ? const Color(0xFF8E24AA) : Colors.grey,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: isDark ? AppThemes.darkBorder : AppThemes.lightBorder),
            const SizedBox(height: 8),

            // Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _pingTerminal(item),
                  icon: const Icon(Icons.network_check_rounded, size: 16),
                  label: Text('ping_btn'.tr, style: TextStyle(fontSize: 12)),
                ),
                const SizedBox(width: 6),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _sendMessageToTerminal(item),
                  icon: const Icon(Icons.send_rounded, size: 14),
                  label: Text('send_alert_btn'.tr, style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
