import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../models/portfolio_request.dart';
import '../providers/firebase_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/glow_background.dart';

class AdminPage extends ConsumerStatefulWidget {
  const AdminPage({super.key});

  @override
  ConsumerState<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends ConsumerState<AdminPage> {
  // Login Panel State
  bool _isMockLoggedIn = false;
  bool _isLoggingIn = false;
  bool _obscurePassword = true;
  String _loginError = '';
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Table Filters State
  String _searchQuery = '';
  String _statusFilter = 'All';
  String _packageFilter = 'All';
  String _sortBy = 'Date (Newest)';

  late Stream<List<PortfolioRequest>> _requestsStream;

  // Supported status values
  final List<String> _statuses = ['Pending', 'Contacted', 'In Progress', 'Completed'];

  @override
  void initState() {
    super.initState();
    _requestsStream = ref.read(firebaseServiceProvider).streamRequests();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isAuthorized {
    final firebaseService = ref.read(firebaseServiceProvider);
    if (firebaseService.isMock) {
      return _isMockLoggedIn;
    } else {
      final user = firebaseService.currentUser;
      return user != null && !user.isAnonymous;
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _loginError = '';
      _isLoggingIn = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = 'Please fill in all fields.';
        _isLoggingIn = false;
      });
      return;
    }

    try {
      final firebaseService = ref.read(firebaseServiceProvider);
      await firebaseService.signInWithEmailAndPassword(email, password);
      
      if (firebaseService.isMock) {
        setState(() {
          _isMockLoggedIn = true;
        });
      } else {
        setState(() {}); // Rebuild to reveal dashboard
      }
    } catch (e) {
      setState(() {
        _loginError = 'Invalid email or password.';
      });
    } finally {
      setState(() {
        _isLoggingIn = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not launch $url: $e');
    }
  }

  void _showDeleteDialog(PortfolioRequest request, FirebaseService service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MUOPTheme.cardBg,
        title: const Text('Delete Request', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete the request for "${request.fullName}" (${request.requestId})?',
          style: const TextStyle(color: MUOPTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: MUOPTheme.secondaryText)),
          ),
          TextButton(
            onPressed: () {
              service.deleteRequest(request.requestId);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Request ${request.requestId} deleted successfully.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginUI() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassCard(
          animateHover: false,
          isHighlighted: true,
          hoverBorderColor: MUOPTheme.primaryYellow,
          hoverGlowColor: MUOPTheme.glowColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 28,
                    width: 28,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'MUOP ADMIN',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter credentials to access the admin panel.',
                style: TextStyle(fontSize: 12, color: MUOPTheme.secondaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email Field
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  labelStyle: const TextStyle(color: MUOPTheme.secondaryText),
                  prefixIcon: const Icon(Icons.email_outlined, color: MUOPTheme.secondaryText),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: MUOPTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: MUOPTheme.primaryYellow),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: const TextStyle(color: MUOPTheme.secondaryText),
                  prefixIcon: const Icon(Icons.lock_outline, color: MUOPTheme.secondaryText),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: MUOPTheme.secondaryText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: MUOPTheme.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: MUOPTheme.primaryYellow),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Error Message
              if (_loginError.isNotEmpty) ...[
                Text(
                  _loginError,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MUOPTheme.primaryYellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isLoggingIn ? null : _handleLogin,
                  child: _isLoggingIn
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Access Portal',
                          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = ref.watch(firebaseServiceProvider);
    final isAuthorized = _isAuthorized;
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MUOPTheme.cardBg,
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 24,
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'MUOP Admin Portal',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: firebaseService.isMock ? Colors.blueGrey.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: firebaseService.isMock ? Colors.blueGrey : Colors.green,
                  width: 0.8,
                ),
              ),
              child: Text(
                firebaseService.isMock ? 'MOCK MODE' : 'LIVE FIREBASE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: firebaseService.isMock ? Colors.blueGrey[200] : Colors.green[200],
                ),
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
        ),
        actions: isAuthorized
            ? [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Sign Out',
                  onPressed: () async {
                    if (firebaseService.isMock) {
                      setState(() {
                        _isMockLoggedIn = false;
                      });
                    } else {
                      await firebaseService.signOut();
                      await firebaseService.signInAnonymously();
                      setState(() {});
                    }
                  },
                ),
              ]
            : null,
      ),
      body: GlowBackground(
        child: !isAuthorized
            ? _buildLoginUI()
            : StreamBuilder<List<PortfolioRequest>>(
                stream: _requestsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: MUOPTheme.primaryYellow));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error loading requests: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    );
                  }

                  final allRequests = snapshot.data ?? [];

                  // Compute Metrics
                  final totalCount = allRequests.length;
                  final studentCount = allRequests.where((r) => r.selectedPackage == 'Student').length;
                  final professionalCount = allRequests.where((r) => r.selectedPackage == 'Professional').length;
                  
                  final now = DateTime.now();
                  final recentCount = allRequests.where((r) {
                    return now.difference(r.createdAt).inHours < 24;
                  }).length;

                  // Apply Search and Filters
                  List<PortfolioRequest> filteredRequests = allRequests.where((req) {
                    final query = _searchQuery.toLowerCase();
                    final matchesSearch = req.fullName.toLowerCase().contains(query) ||
                        req.email.toLowerCase().contains(query) ||
                        req.whatsapp.toLowerCase().contains(query) ||
                        req.desiredRole.toLowerCase().contains(query) ||
                        req.requestId.toLowerCase().contains(query);

                    final matchesStatus = _statusFilter == 'All' || req.requestStatus == _statusFilter;
                    final matchesPackage = _packageFilter == 'All' || req.selectedPackage == _packageFilter;

                    return matchesSearch && matchesStatus && matchesPackage;
                  }).toList();

                  // Apply Sort
                  if (_sortBy == 'Date (Newest)') {
                    filteredRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
                  } else if (_sortBy == 'Date (Oldest)') {
                    filteredRequests.sort((a, b) => a.createdAt.compareTo(b.createdAt));
                  } else if (_sortBy == 'Request ID (Asc)') {
                    filteredRequests.sort((a, b) => a.requestId.compareTo(b.requestId));
                  } else if (_sortBy == 'Request ID (Desc)') {
                    filteredRequests.sort((a, b) => b.requestId.compareTo(a.requestId));
                  } else if (_sortBy == 'Name') {
                    filteredRequests.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metrics grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final cols = constraints.maxWidth < 600 ? 2 : 4;
                            final cardWidth = (constraints.maxWidth - (cols - 1) * 16) / cols;
                            
                            return Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                _buildMetricCard('Total Requests', '$totalCount', Icons.folder_open, cardWidth),
                                _buildMetricCard('Student Package', '$studentCount', Icons.school_outlined, cardWidth),
                                _buildMetricCard('Professional Package', '$professionalCount', Icons.workspace_premium_outlined, cardWidth),
                                _buildMetricCard('Recent (24h)', '$recentCount', Icons.hourglass_empty, cardWidth),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 32),

                        // Table controls and content
                        GlassCard(
                          animateHover: false,
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registrations Management',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 16),
                              
                              // Search and filters row
                              LayoutBuilder(
                                builder: (context, controlsConstraints) {
                                  final isCompact = controlsConstraints.maxWidth < 900;
                                  
                                  final searchField = SizedBox(
                                    width: isCompact ? double.infinity : 280,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search request, name, role...',
                                        prefixIcon: const Icon(Icons.search, size: 20, color: MUOPTheme.secondaryText),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: MUOPTheme.border),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: MUOPTheme.primaryYellow),
                                        ),
                                      ),
                                      onChanged: (val) {
                                        setState(() {
                                          _searchQuery = val;
                                        });
                                      },
                                    ),
                                  );

                                  final filters = Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      _buildDropdownFilter(
                                        label: 'Status',
                                        value: _statusFilter,
                                        items: ['All', 'Pending', 'Contacted', 'In Progress', 'Completed'],
                                        onChanged: (val) => setState(() => _statusFilter = val!),
                                      ),
                                      _buildDropdownFilter(
                                        label: 'Package',
                                        value: _packageFilter,
                                        items: ['All', 'Student', 'Professional'],
                                        onChanged: (val) => setState(() => _packageFilter = val!),
                                      ),
                                      _buildDropdownFilter(
                                        label: 'Sort By',
                                        value: _sortBy,
                                        items: ['Date (Newest)', 'Date (Oldest)', 'Request ID (Asc)', 'Request ID (Desc)', 'Name'],
                                        onChanged: (val) => setState(() => _sortBy = val!),
                                      ),
                                    ],
                                  );

                                  if (isCompact) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        searchField,
                                        const SizedBox(height: 16),
                                        filters,
                                      ],
                                    );
                                  } else {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        searchField,
                                        filters,
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 20),

                              // Data Table
                              if (filteredRequests.isEmpty)
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F0F0F),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: MUOPTheme.border),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'No requests found matching filters.',
                                      style: TextStyle(color: MUOPTheme.secondaryText),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: MUOPTheme.border, width: 1.0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        headingRowColor: MaterialStateProperty.all(const Color(0xFF161616)),
                                        dataRowHeight: 64,
                                        columns: const [
                                          DataColumn(label: Text('Request ID', style: TextStyle(fontWeight: FontWeight.bold, color: MUOPTheme.primaryYellow))),
                                          DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Email', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Role', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Package', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                                        ],
                                        rows: filteredRequests.map((req) {
                                          final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(req.createdAt);
                                          
                                          return DataRow(
                                            cells: [
                                              DataCell(Text(req.requestId, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                              DataCell(Text(req.fullName)),
                                              DataCell(Text(req.email)),
                                              DataCell(Text(req.whatsapp)),
                                              DataCell(Text(req.desiredRole)),
                                              DataCell(
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: req.selectedPackage == 'Professional' 
                                                        ? MUOPTheme.primaryYellow.withOpacity(0.1) 
                                                        : Colors.white.withOpacity(0.05),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(
                                                      color: req.selectedPackage == 'Professional' 
                                                          ? MUOPTheme.primaryYellow 
                                                          : MUOPTheme.border,
                                                      width: 0.5,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    req.selectedPackage,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: req.selectedPackage == 'Professional' ? MUOPTheme.primaryYellow : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(Text(formattedDate, style: const TextStyle(fontSize: 12, color: MUOPTheme.secondaryText))),
                                              DataCell(
                                                DropdownButtonHideUnderline(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(4),
                                                      border: Border.all(color: MUOPTheme.border),
                                                      color: const Color(0xFF161616),
                                                    ),
                                                    child: DropdownButton<String>(
                                                      value: _statuses.contains(req.requestStatus) ? req.requestStatus : 'Pending',
                                                      dropdownColor: MUOPTheme.cardBg,
                                                      style: const TextStyle(fontSize: 13, color: Colors.white),
                                                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                                      onChanged: (newStatus) {
                                                        if (newStatus != null) {
                                                          firebaseService.updateRequestStatus(req.requestId, newStatus);
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              DataCell(
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.file_download_outlined, color: MUOPTheme.primaryYellow, size: 20),
                                                      tooltip: 'Download Resume',
                                                      onPressed: req.resumeUrl.isEmpty 
                                                          ? null 
                                                          : () => _launchUrl(req.resumeUrl),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                                      tooltip: 'Delete Request',
                                                      onPressed: () => _showDeleteDialog(req, firebaseService),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: MUOPTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MUOPTheme.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: MUOPTheme.secondaryText.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: MUOPTheme.primaryYellow,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: MUOPTheme.primaryYellow, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(fontSize: 12, color: MUOPTheme.secondaryText.withOpacity(0.6), fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        DropdownButtonHideUnderline(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: MUOPTheme.border),
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFF161616),
            ),
            child: DropdownButton<String>(
              value: value,
              dropdownColor: MUOPTheme.cardBg,
              style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
              icon: const Icon(Icons.arrow_drop_down, color: MUOPTheme.secondaryText, size: 18),
              onChanged: onChanged,
              items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
