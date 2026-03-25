import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:valarpay/features/notifiers/remita_notifier.dart';

class RemitaCategoriesScreen extends ConsumerStatefulWidget {
  const RemitaCategoriesScreen({super.key});

  @override
  ConsumerState<RemitaCategoriesScreen> createState() => _RemitaCategoriesScreenState();
}

class _RemitaCategoriesScreenState extends ConsumerState<RemitaCategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(remitaCategoriesProvider.notifier).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remitaCategoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Bill Categories'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isInitialLoading
          ? const SizedBox.shrink()
          : state.message != null
              ? Center(child: Text(state.message!, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: state.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final category = state.data![index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        leading: Container(
                          width: 48.w,
                          height: 48.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIcon(category.categoryId),
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                          category.categoryName,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          context.push('/remita-billing/${category.categoryId}/${category.categoryName}');
                        },
                      ),
                    );
                  },
                ),
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId.toLowerCase()) {
      case 'airtime':
        return Icons.phone_android;
      case 'data':
        return Icons.data_usage;
      case 'electricity':
        return Icons.lightbulb_outline;
      case 'paytv':
        return Icons.tv;
      case 'internet':
        return Icons.language;
      case 'education':
      case 'school':
        return Icons.school;
      case 'transport':
      case 'transportation':
        return Icons.directions_bus;
      case 'flight':
        return Icons.flight;
      case 'insurance':
        return Icons.security;
      case 'water':
        return Icons.water_drop;
      default:
        return Icons.receipt_long;
    }
  }
}
