import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/auth_provider.dart';
import '../../services/auth_service.dart';
import '../screens/admin_dashboard_screen.dart';

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
                          leading: const Icon(Icons.logout, color: Colors.red),
                          title: const Text('Sign Out',
                              style: TextStyle(color: Colors.red)),
                          onTap: () async {
                            await ref.read(authActionsProvider).signOut();
                            if (context.mounted) Navigator.pop(context);
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
