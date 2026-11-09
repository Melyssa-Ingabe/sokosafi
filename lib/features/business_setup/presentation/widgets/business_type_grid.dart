import 'package:flutter/material.dart';
import 'package:sokosafi/core/constants/app_spacing.dart';
import 'package:sokosafi/features/business_setup/domain/entities/business_type.dart';
import 'package:sokosafi/features/business_setup/presentation/widgets/business_type_tile.dart';

/// Two columns on phones, four when there is room (landscape, tablets).
class BusinessTypeGrid extends StatelessWidget {
  const BusinessTypeGrid({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final BusinessType? selected;
  final ValueChanged<BusinessType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 560 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: BusinessType.values.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            mainAxisExtent: 88,
          ),
          itemBuilder: (context, index) {
            final type = BusinessType.values[index];
            return BusinessTypeTile(
              type: type,
              isSelected: type == selected,
              onTap: () => onSelected(type),
            );
          },
        );
      },
    );
  }
}
