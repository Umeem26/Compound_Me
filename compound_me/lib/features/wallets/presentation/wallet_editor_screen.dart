import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/money.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/wallets/data/drift_wallet_repository.dart';
import 'package:compound_me/features/wallets/domain/wallet.dart';
import 'package:compound_me/features/wallets/presentation/wallet_labels.dart';
import 'package:compound_me/features/wallets/presentation/wallet_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum WalletEditAction { archived, deleted }

/// Returned to the wallet list so it can offer an undo snackbar.
typedef WalletEditOutcome = ({WalletEditAction action, Wallet wallet});

/// New or existing wallet (S-41): name, type, icon, color and starting
/// balance. An existing wallet can be archived when it has transactions
/// or deleted when it has none, but never the last active one.
class WalletEditorScreen extends ConsumerWidget {
  const WalletEditorScreen({this.walletId, super.key});

  /// Null for a new wallet.
  final String? walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = walletId;
    if (id == null) return const _WalletForm(source: null);
    final l10n = context.l10n;
    final source = ref.watch(walletEditorSourceProvider(id));
    return switch (source) {
      AsyncData(:final value?) => _WalletForm(source: value),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: AppIcons.wallet,
          title: l10n.walletsEmptyTitle,
          message: l10n.errorLoadBody,
        ),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: AsyncBody<void>(
          value: source,
          data: (_) => const SizedBox.shrink(),
          errorLabels: l10n.loadErrorLabels,
          onRetry: () => ref.invalidate(walletEditorSourceProvider(id)),
        ),
      ),
    };
  }
}

class _WalletForm extends ConsumerStatefulWidget {
  const _WalletForm({required this.source});

  final WalletEditorSource? source;

  @override
  ConsumerState<_WalletForm> createState() => _WalletFormState();
}

class _WalletFormState extends ConsumerState<_WalletForm> {
  late final Wallet? _wallet = widget.source?.wallet;
  late final TextEditingController _name = TextEditingController(
    text: _wallet?.name ?? '',
  );
  late WalletType _type = _wallet?.type ?? WalletType.cash;
  late String _iconKey = _wallet?.iconKey ?? _type.defaultIconKey;
  late String _colorKey = _wallet?.colorKey ?? AppPresetColor.teal.key;
  late Money _initialBalance = _wallet?.initialBalance ?? 0;

  /// A new wallet's icon follows its type until the user picks one.
  late bool _iconPicked = _wallet != null;
  String? _nameError;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickType() async {
    final l10n = context.l10n;
    final type = await showOptionSheet<WalletType>(
      context,
      title: l10n.fieldWalletType,
      selected: _type,
      options: [
        for (final type in WalletType.values)
          SheetOption(
            value: type,
            label: walletTypeLabel(l10n, type),
            icon: AppIcons.byKey[type.defaultIconKey],
          ),
      ],
    );
    if (type == null) return;
    setState(() {
      _type = type;
      if (!_iconPicked) _iconKey = type.defaultIconKey;
    });
  }

  Future<void> _pickIcon() async {
    final l10n = context.l10n;
    final key = await showIconPickerSheet(
      context,
      title: l10n.iconPickerTitle,
      selectedKey: _iconKey,
      colorKey: _colorKey,
      semanticLabel: l10n.iconPosition,
    );
    if (key != null) {
      setState(() {
        _iconKey = key;
        _iconPicked = true;
      });
    }
  }

  Future<void> _editBalance() async {
    final l10n = context.l10n;
    final amount = await showAmountSheet(
      context,
      title: l10n.fieldInitialBalance,
      initial: _initialBalance,
      saveLabel: l10n.actionSave,
      backspaceLabel: l10n.keypadBackspace,
    );
    if (amount != null) setState(() => _initialBalance = amount);
  }

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await action();
    } on ValidationException {
      setState(() => _nameError = l10n.errorNameRequired);
    } on Object {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorSaveFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _nameError = context.l10n.errorNameRequired);
      return;
    }
    final draft = WalletDraft(
      name: _name.text,
      type: _type,
      iconKey: _iconKey,
      colorKey: _colorKey,
      initialBalance: _initialBalance,
    );
    final navigator = Navigator.of(context);
    await _run(() async {
      final repository = ref.read(walletRepositoryProvider);
      final wallet = _wallet;
      if (wallet == null) {
        await repository.create(draft);
      } else {
        await repository.update(wallet.id, draft);
      }
      navigator.pop();
    });
  }

  Future<void> _archiveOrDelete(WalletEditAction action) async {
    final wallet = _wallet!;
    final navigator = Navigator.of(context);
    await _run(() async {
      final repository = ref.read(walletRepositoryProvider);
      switch (action) {
        case WalletEditAction.archived:
          await repository.archive(wallet.id);
        case WalletEditAction.deleted:
          await repository.delete(wallet.id);
      }
      navigator.pop<WalletEditOutcome>((action: action, wallet: wallet));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final source = widget.source;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(AppIcons.x),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          source == null ? l10n.walletNewTitle : l10n.walletEditTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.space4,
          AppSpacing.screenHorizontal,
          AppSpacing.space8,
        ),
        children: [
          Center(
            child: IconBadge(
              iconKey: _iconKey,
              colorKey: _colorKey,
              size: AppSizes.avatar,
              iconSize: AppSizes.iconLg,
            ),
          ),
          const SizedBox(height: AppSpacing.space6),
          AppTextField(
            label: l10n.fieldWalletName,
            controller: _name,
            errorText: _nameError,
            maxLength: walletNameMaxLength,
            autofocus: source == null,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) {
              if (_nameError != null) setState(() => _nameError = null);
            },
          ),
          const SizedBox(height: AppSpacing.space4),
          RowPicker(
            label: l10n.fieldWalletType,
            value: walletTypeLabel(l10n, _type),
            onTap: _pickType,
          ),
          const SizedBox(height: AppSpacing.space2),
          RowPicker(
            label: l10n.fieldIcon,
            value: '',
            leading: IconBadge(iconKey: _iconKey, colorKey: _colorKey),
            onTap: _pickIcon,
          ),
          const SizedBox(height: AppSpacing.space4),
          Text(
            l10n.fieldColor,
            style: AppTextStyles.label.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.space1),
          ColorPicker(
            selectedKey: _colorKey,
            onChanged: (key) => setState(() => _colorKey = key),
            semanticLabel: l10n.presetColorName,
          ),
          const SizedBox(height: AppSpacing.space4),
          RowPicker(
            label: l10n.fieldInitialBalance,
            value: formatRupiah(_initialBalance),
            onTap: _editBalance,
          ),
          if (source != null) ...[
            const SizedBox(height: AppSpacing.space2),
            Text(
              l10n.walletBalanceHelper,
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.space6),
            AppListGroup(
              children: [
                if (source.inUse)
                  AppListTile(
                    title: l10n.walletArchive,
                    subtitle: source.lastActive
                        ? l10n.walletLastActive
                        : l10n.walletArchiveHint,
                    showChevron: false,
                    onTap: source.lastActive || _busy
                        ? null
                        : () => _archiveOrDelete(WalletEditAction.archived),
                  )
                else
                  AppListTile(
                    title: l10n.walletDelete,
                    subtitle: source.lastActive
                        ? l10n.walletLastActive
                        : l10n.walletDeleteHint,
                    destructive: !source.lastActive,
                    showChevron: false,
                    onTap: source.lastActive || _busy
                        ? null
                        : () => _archiveOrDelete(WalletEditAction.deleted),
                  ),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.space3,
            AppSpacing.screenHorizontal,
            AppSpacing.space4,
          ),
          child: PrimaryButton(
            label: l10n.actionSave,
            loading: _busy,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
