import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../state/auth_provider.dart';
import '../../state/study_layout_provider.dart';
import '../../services/cloud_sync_service.dart';
import 'textured_glass_container.dart';
import 'mesh_gradient_bg.dart';

class AccountSyncCard extends ConsumerStatefulWidget {
  final CardSize size;
  const AccountSyncCard({super.key, required this.size});

  @override
  ConsumerState<AccountSyncCard> createState() => _AccountSyncCardState();
}

class _AccountSyncCardState extends ConsumerState<AccountSyncCard> {
  bool _isSyncing = false;
  DateTime? _lastSynced;

  @override
  void initState() {
    super.initState();
    _loadLastSync();
  }

  Future<void> _loadLastSync() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt('last_cloud_sync_timestamp');
    if (ts != null) {
      if (mounted) {
        setState(() {
          _lastSynced = DateTime.fromMillisecondsSinceEpoch(ts);
        });
      }
    }
  }

  Future<void> _triggerSync() async {
    if (_isSyncing) return;
    setState(() => _isSyncing = true);
    
    try {
      await ref.read(cloudSyncServiceProvider).syncData();
      await _loadLastSync();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sync complete! Latest changes merged.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync. Check network.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final theme = Theme.of(context);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: RepaintBoundary(
        child: AnimatedMeshGradient(
          borderRadius: 28,
          child: TexturedGlassContainer(
            isScrollable: false,
            borderRadius: BorderRadius.circular(28),
            padding: const EdgeInsets.all(24),
            child: user == null ? _buildLoggedOut(theme) : _buildLoggedIn(theme, user),
          ),
        ),
      ),
    );
  }

  Widget _buildLoggedOut(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cloud_sync_rounded, color: theme.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              'CLOUD SYNC',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.primaryColor,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Sync Your Journey',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Backup your highlights, bookmarks, and streaks across all your devices securely.',
          style: theme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _signInWithGoogle(),
            icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
            label: const Text('Continue with Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: theme.colorScheme.onSurface,
              elevation: 0,
              side: BorderSide(color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _signInWithApple(),
            icon: const Icon(Icons.apple, size: 24),
            label: const Text('Continue with Apple'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.onSurface,
              foregroundColor: theme.colorScheme.surface,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedIn(ThemeData theme, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL) : null,
                  child: user.photoURL == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? 'Signed In',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user.email ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.settings_rounded),
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              onPressed: () => _showManageDataSheet(context, theme),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.primaryColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _lastSynced != null ? 'Last synced ${_formatTimeAgo(_lastSynced!)}' : 'Ready to sync',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Latest highlights win on merge.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              _isSyncing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: Icon(Icons.sync_rounded, color: theme.primaryColor),
                      onPressed: _triggerSync,
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    final result = await ref.read(authActionsProvider).signInWithGoogle();
    if (mounted && result == SignInResult.success) {
      _triggerSync();
    }
  }

  Future<void> _signInWithApple() async {
    final result = await ref.read(authActionsProvider).signInWithApple();
    if (mounted && result == SignInResult.success) {
      _triggerSync();
    }
  }

  void _showManageDataSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.cloud_off_rounded, color: Colors.orange),
                  title: const Text('Sign Out', style: TextStyle(color: Colors.orange)),
                  subtitle: const Text('Your local data will remain.'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(authActionsProvider).signOut();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                  title: const Text('Reset Local Data', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Clear local device highlights & bookmarks.'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await _confirmDialog(context, 'Reset Local Data?', 'This clears your local database. Your cloud data is untouched.');
                    if (confirm == true) {
                      await ref.read(cloudSyncServiceProvider).resetLocalData();
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Permanently erase all cloud data and sign out.'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final confirm = await _confirmDialog(context, 'Delete Account?', 'This is permanent and irreversible. All cloud backups will be deleted.');
                    if (confirm == true) {
                      try {
                        await ref.read(authActionsProvider).deleteAccount();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account deleted successfully.')));
                      } catch (e) {
                         if (!mounted) return;
                         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: ${e.toString()}')));
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool?> _confirmDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
