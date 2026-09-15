import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_provider.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_constants.dart';

class AccountButton extends ConsumerWidget {
  const AccountButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    final theme = Theme.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Consumer(
              builder: (context, ref, child) {
                final currentAuthState = ref.watch(authStateProvider);
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          currentAuthState.value != null ? 'Account' : 'Sign In',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (currentAuthState.value == null) ...[
                        ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: const Text('Sign in with Google'),
                          onTap: () async {
                            final result = await ref
                                .read(authActionsProvider)
                                .signInWithGoogle();
                            if (context.mounted && result == SignInResult.failed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Sign in failed. Please try again.'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                            if (context.mounted && result == SignInResult.success) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.apple),
                          title: const Text('Sign in with Apple'),
                          onTap: () async {
                            final result = await ref
                                .read(authActionsProvider)
                                .signInWithApple();
                            if (context.mounted && result == SignInResult.failed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Sign in failed. Please try again.'),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                              );
                            }
                            if (context.mounted && result == SignInResult.success) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ] else ...[
                        ListTile(
                          leading: CircleAvatar(
                            radius: 12,
                            backgroundImage: currentAuthState.value?.photoURL != null
                                ? NetworkImage(currentAuthState.value!.photoURL!)
                                : null,
                            child: currentAuthState.value?.photoURL == null
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          title: Text(currentAuthState.value?.displayName ?? 'Signed In'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.logout, color: Colors.orange),
                          title: const Text('Sign Out',
                              style: TextStyle(color: Colors.orange)),
                          onTap: () async {
                            await ref.read(authActionsProvider).signOut();
                            if (context.mounted) Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: Colors.red),
                          title: const Text('Delete Account',
                              style: TextStyle(color: Colors.red)),
                          onTap: () async {
                            // Close the bottom sheet first
                            Navigator.pop(context);
                            // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Account?'),
                                content: const Text(
                                    'This is permanent and irreversible.\n\n'
                                    'The following will be completely removed:\n'
                                    '• Your sign-in account\n'
                                    '• Your cloud-synced custom plans\n'
                                    '• All on-device study data (bookmarks, highlights, history)'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true && context.mounted) {
                              try {
                                await ref.read(authActionsProvider).deleteAccount();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Account deleted successfully.')),
                                  );
                                }
                              } on ReauthCancelledException catch (_) {
                                // Ignore cancellation silently
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to delete account: ${e.toString().replaceAll("Exception: ", "")}'),
                                      duration: const Duration(seconds: 4),
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        ),
                        if (currentAuthState.value?.uid == kOwnerUid)
                          ListTile(
                            leading: const Icon(Icons.admin_panel_settings,
                                color: Colors.blue),
                            title: const Text('Admin Panel',
                                style: TextStyle(color: Colors.blue)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (_) => const AdminDashboardScreen()));
                            },
                          ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Builder(builder: (context) {
        if (user == null) {
          return Icon(Icons.person_outline_rounded,
              size: 28, color: theme.colorScheme.onSurface);
        }

        Widget fallbackIcon;
        final name = user.displayName?.trim() ?? '';
        if (name.isNotEmpty) {
          fallbackIcon = SizedBox(
            width: 28,
            height: 28,
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        } else {
          fallbackIcon = Icon(Icons.person_outline_rounded,
              size: 28, color: theme.colorScheme.onSurface);
        }

        if (user.photoURL != null) {
          return Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: ClipOval(
              child: Image.network(
                user.photoURL!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallbackIcon,
              ),
            ),
          );
        }

        return fallbackIcon;
      }),
    );
  }
}
