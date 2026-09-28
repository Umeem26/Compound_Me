import 'package:compound_me/core/design/design.dart';
import 'package:compound_me/core/l10n/category_names.dart';
import 'package:compound_me/core/l10n/design_labels.dart';
import 'package:compound_me/core/l10n/l10n.dart';
import 'package:compound_me/core/utils/validation.dart';
import 'package:compound_me/features/categories/data/drift_category_repository.dart';
import 'package:compound_me/features/categories/domain/category.dart';
import 'package:compound_me/features/categories/presentation/category_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CategoryEditAction { archived, deleted }

/// Returned to the category list so it can offer an undo snackbar.
typedef CategoryEditOutcome = ({CategoryEditAction action, Category category});

/// New or existing category (S-42). Default categories keep their
/// translated name; icon and color can always change. A category in use
/// can only be archived, an unused one deleted.
class CategoryEditorScreen extends ConsumerWidget {
  const CategoryEditorScreen({
    this.categoryId,
    this.kind = CategoryKind.expense,
    super.key,
  });

  /// Null for a new category of [kind].
  final String? categoryId;
  final CategoryKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = categoryId;
    if (id == null) return _CategoryForm(source: null, kind: kind);
    final l10n = context.l10n;
    final source = ref.watch(categoryEditorSourceProvider(id));
    return switch (source) {
      AsyncData(:final value?) => _CategoryForm(
        source: value,
        kind: value.category.kind,
      ),
      AsyncData() => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: AppIcons.receipt,
          title: l10n.categoriesEmptyTitle,
          message: l10n.errorLoadBody,
        ),
      ),
      _ => Scaffold(
        appBar: AppBar(),
        body: AsyncBody<void>(
          value: source,
          data: (_) => const SizedBox.shrink(),
          errorLabels: l10n.loadErrorLabels,
          onRetry: () => ref.invalidate(categoryEditorSourceProvider(id)),
        ),
      ),
    };
  }
}

class _CategoryForm extends ConsumerStatefulWidget {
  const _CategoryForm({required this.source, required this.kind});

  final CategoryEditorSource? source;
  final CategoryKind kind;

  @override
  ConsumerState<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<_CategoryForm> {
  late final Category? _category = widget.source?.category;
  TextEditingController? _name;
  late String _iconKey = _category?.iconKey ?? AppIcons.byKey.keys.first;
  late String _colorKey = _category?.colorKey ?? AppPresetColor.teal.key;
  String? _nameError;
  bool _busy = false;

  /// Anything differing from what the form opened with (03 §4). Default
  /// names can't be edited, so only custom names count.
  bool get _hasChanges {
    final category = _category;
    final nameChanged =
        !_isDefault && _name!.text.trim() != (category?.customName ?? '');
    return nameChanged ||
        _iconKey != (category?.iconKey ?? AppIcons.byKey.keys.first) ||
        _colorKey != (category?.colorKey ?? AppPresetColor.teal.key);
  }

  bool get _isDefault => _category?.isDefault ?? false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Default names are translated, so they are read here with l10n.
    final category = _category;
    _name ??= TextEditingController(
      text: category == null ? '' : categoryName(context.l10n, category),
    );
  }

  @override
  void dispose() {
    _name?.dispose();
    super.dispose();
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
    if (key != null) setState(() => _iconKey = key);
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
    if (!_isDefault && _name!.text.trim().isEmpty) {
      setState(() => _nameError = context.l10n.errorNameRequired);
      return;
    }
    final navigator = Navigator.of(context);
    await _run(() async {
      final repository = ref.read(categoryRepositoryProvider);
      final category = _category;
      if (category == null) {
        await repository.create(
          CategoryDraft(
            kind: widget.kind,
            name: _name!.text,
            iconKey: _iconKey,
            colorKey: _colorKey,
          ),
        );
      } else {
        await repository.update(
          category.id,
          name: category.isDefault ? null : _name!.text,
          iconKey: _iconKey,
          colorKey: _colorKey,
        );
      }
      navigator.pop();
    });
  }

  Future<void> _archiveOrDelete(CategoryEditAction action) async {
    final category = _category!;
    final navigator = Navigator.of(context);
    await _run(() async {
      final repository = ref.read(categoryRepositoryProvider);
      switch (action) {
        case CategoryEditAction.archived:
          await repository.archive(category.id);
        case CategoryEditAction.deleted:
          await repository.delete(category.id);
      }
      navigator.pop<CategoryEditOutcome>((action: action, category: category));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.tokens.colors;
    final source = widget.source;
    return UnsavedChangesGuard(
      hasChanges: _hasChanges,
      labels: l10n.discardLabels,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(AppIcons.x),
            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            source == null ? l10n.categoryNewTitle : l10n.categoryEditTitle,
          ),
        ),
        // The save button sits in the body so it rises above the keyboard;
        // as a bottom bar it would stay hidden behind it.
        body: Column(
          children: [
            Expanded(
              child: ListView(
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
                    label: l10n.fieldCategoryName,
                    controller: _name!,
                    enabled: !_isDefault,
                    errorText: _nameError,
                    helperText: _isDefault
                        ? l10n.categoryDefaultNameHelper
                        : null,
                    maxLength: categoryNameMaxLength,
                    autofocus: source == null,
                    // Rebuilds on every change so the discard guard knows.
                    onChanged: (_) => setState(() => _nameError = null),
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  RowPicker(
                    label: l10n.fieldIcon,
                    value: '',
                    leading: IconBadge(iconKey: _iconKey, colorKey: _colorKey),
                    onTap: _pickIcon,
                  ),
                  const SizedBox(height: AppSpacing.space4),
                  Text(
                    l10n.fieldColor,
                    style: AppTextStyles.label.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.space1),
                  ColorPicker(
                    selectedKey: _colorKey,
                    onChanged: (key) => setState(() => _colorKey = key),
                    semanticLabel: l10n.presetColorName,
                  ),
                  if (source != null) ...[
                    const SizedBox(height: AppSpacing.space6),
                    AppListGroup(
                      children: [
                        if (source.inUse)
                          AppListTile(
                            title: l10n.categoryArchive,
                            subtitle: l10n.categoryArchiveHint,
                            showChevron: false,
                            onTap: _busy
                                ? null
                                : () => _archiveOrDelete(
                                    CategoryEditAction.archived,
                                  ),
                          )
                        else
                          AppListTile(
                            title: l10n.categoryDelete,
                            subtitle: l10n.categoryDeleteHint,
                            destructive: true,
                            showChevron: false,
                            onTap: _busy
                                ? null
                                : () => _archiveOrDelete(
                                    CategoryEditAction.deleted,
                                  ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
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
          ],
        ),
      ),
    );
  }
}
