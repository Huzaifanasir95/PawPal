import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/widgets/custom_search_bar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../data/models/vet_profile_model.dart';
import '../bloc/vet_bloc.dart';
import '../bloc/vet_event.dart';
import '../bloc/vet_state.dart';
import 'vet_detail_screen.dart';

enum _VetQuickFilter { all, topRated, affordable, availableNow }

class VetsListScreen extends StatefulWidget {
  const VetsListScreen({super.key});

  @override
  State<VetsListScreen> createState() => _VetsListScreenState();
}

class _VetsListScreenState extends State<VetsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';
  _VetQuickFilter _activeQuickFilter = _VetQuickFilter.all;
  
  String? _filterCity;
  String? _filterSpecialization;
  double? _filterMinRating;
  
  List<VetProfile> _cachedVets = [];
  bool _cachedHasMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<VetBloc>().add(const VetEvent.listVets());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_searchQuery.trim().isNotEmpty) return;

    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
      final currentState = context.read<VetBloc>().state;
      currentState.maybeWhen(
        vetsListLoaded: (vets, total, currentPage, limit, hasMore, city, spec, rating) {
          if (hasMore) {
            context.read<VetBloc>().add(VetEvent.listVets(
              city: city,
              specialization: spec,
              minRating: rating,
              page: currentPage + 1,
              limit: limit,
            ));
          }
        },
        orElse: () {},
      );
    }
  }

  bool get _hasActiveFilters =>
      _filterCity != null || _filterSpecialization != null || _filterMinRating != null;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -80.h,
                right: -50.w,
                child: Container(
                  width: 180.w,
                  height: 180.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: 140.h,
                left: -40.w,
                child: Container(
                  width: 130.w,
                  height: 130.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildQuickFilters(),
                  Expanded(child: _buildVetsList()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.24),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find a Vet',
                  style: TextStyle(
                    fontSize: 24.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Book appointments with verified vets',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: _hasActiveFilters ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.24),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.tune_rounded,
                      color: _hasActiveFilters
                          ? Theme.of(context).colorScheme.surface
                          : Theme.of(context).colorScheme.onPrimary,
                      size: 22.sp,
                    ),
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return CustomSearchBar(
      controller: _searchController,
      hintText: 'Search by name or specialization...',
      onChanged: (value) {
        setState(() {
          _searchQuery = value.trim().toLowerCase();
        });
      },
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
    );
  }

  Widget _buildQuickFilters() {
    Widget buildChip({
      required _VetQuickFilter filter,
      required String label,
      required IconData icon,
    }) {
      final selected = _activeQuickFilter == filter;
      return GestureDetector(
        onTap: () {
          setState(() {
            _activeQuickFilter = filter;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.8),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: selected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: selected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 14.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            buildChip(
              filter: _VetQuickFilter.all,
              label: 'All',
              icon: Icons.grid_view_rounded,
            ),
            SizedBox(width: 8.w),
            buildChip(
              filter: _VetQuickFilter.topRated,
              label: 'Top Rated',
              icon: Icons.star_rounded,
            ),
            SizedBox(width: 8.w),
            buildChip(
              filter: _VetQuickFilter.affordable,
              label: 'Under PKR 2000',
              icon: Icons.payments_rounded,
            ),
            SizedBox(width: 8.w),
            buildChip(
              filter: _VetQuickFilter.availableNow,
              label: 'Available',
              icon: Icons.circle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVetsList() {
    return BlocConsumer<VetBloc, VetState>(
      listener: (context, state) {
        state.maybeWhen(
          vetsListLoaded: (vets, total, page, limit, hasMore, _, __, ___) {
            setState(() {
              _cachedVets = vets;
              _cachedHasMore = hasMore;
            });
          },
          error: (message) => CustomSnackbar.showError(context, message),
          orElse: () {},
        );
      },
      builder: (context, state) {
        return state.when(
          initial: () => _buildEmptyState(),
          loading: () {
            if (_cachedVets.isNotEmpty) {
              return _buildList(_cachedVets, _cachedHasMore);
            }
            return _buildLoadingState();
          },
          profileLoaded: (_) {
            if (_cachedVets.isNotEmpty) {
              return _buildList(_cachedVets, _cachedHasMore);
            }
            return const SizedBox();
          },
          vetsListLoaded: (vets, total, page, limit, hasMore, _, __, ___) {
            return _buildList(vets, hasMore);
          },
          profileSaved: (_) {
            if (_cachedVets.isNotEmpty) {
              return _buildList(_cachedVets, _cachedHasMore);
            }
            return const SizedBox();
          },
          error: (message) => _buildErrorState(message),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 4,
      itemBuilder: (context, index) => _buildShimmerCard(),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasSearch ? Icons.search_off_rounded : Icons.medical_services_outlined,
            size: 64.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6).withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            hasSearch ? 'No matching vets' : 'No vets found',
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            hasSearch
                ? 'Try another name or specialization keyword'
                : 'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          if (_hasActiveFilters || hasSearch || _activeQuickFilter != _VetQuickFilter.all) ...[
            SizedBox(height: 20.h),
            TextButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _activeQuickFilter = _VetQuickFilter.all;
                  _filterCity = null;
                  _filterSpecialization = null;
                  _filterMinRating = null;
                });
                context.read<VetBloc>().add(const VetEvent.clearFilters());
              },
              child: Text(
                'Clear Filters',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18.sp,
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            GestureDetector(
              onTap: () => context.read<VetBloc>().add(const VetEvent.listVets()),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Try Again',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<VetProfile> vets, bool hasMore) {
    var filteredVets = _searchQuery.isEmpty
        ? vets
        : vets.where((vet) {
            final name = vet.fullName.toLowerCase();
            final degree = vet.degree.toLowerCase();
            final city = (vet.city ?? '').toLowerCase();
            final clinic = (vet.clinicName ?? '').toLowerCase();
            final specs = vet.specialization.join(' ').toLowerCase();

            return name.contains(_searchQuery) ||
                degree.contains(_searchQuery) ||
                city.contains(_searchQuery) ||
                clinic.contains(_searchQuery) ||
                specs.contains(_searchQuery);
          }).toList();

    switch (_activeQuickFilter) {
      case _VetQuickFilter.all:
        break;
      case _VetQuickFilter.topRated:
        filteredVets = filteredVets.where((v) => v.rating >= 4.5).toList();
        break;
      case _VetQuickFilter.affordable:
        filteredVets =
            filteredVets.where((v) => v.consultationFee <= 2000).toList();
        break;
      case _VetQuickFilter.availableNow:
        filteredVets = filteredVets.where((v) => v.isAvailable).toList();
        break;
    }

    if (filteredVets.isEmpty) return _buildEmptyState();

    final showPaginationLoader = hasMore &&
        _searchQuery.isEmpty &&
        _activeQuickFilter == _VetQuickFilter.all;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<VetBloc>().add(VetEvent.listVets(
          city: _filterCity,
          specialization: _filterSpecialization,
          minRating: _filterMinRating,
        ));
      },
      color: Theme.of(context).colorScheme.primary,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
        itemCount: filteredVets.length + (showPaginationLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= filteredVets.length) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          return _VetCard(vet: filteredVets[index], index: index);
        },
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        initialCity: _filterCity,
        initialSpecialization: _filterSpecialization,
        initialMinRating: _filterMinRating,
        onApply: (city, specialization, minRating) {
          setState(() {
            _filterCity = city;
            _filterSpecialization = specialization;
            _filterMinRating = minRating;
          });
          context.read<VetBloc>().add(VetEvent.filterVets(
            city: city,
            specialization: specialization,
            minRating: minRating,
          ));
        },
        onClear: () {
          setState(() {
            _filterCity = null;
            _filterSpecialization = null;
            _filterMinRating = null;
          });
          context.read<VetBloc>().add(const VetEvent.clearFilters());
        },
      ),
    );
  }
}

class _VetCard extends StatelessWidget {
  final VetProfile vet;
  final int index;

  const _VetCard({required this.vet, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1, end: 0),
      duration: Duration(milliseconds: 260 + (index * 70)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: 1 - value,
          child: Transform.translate(
            offset: Offset(0, 20 * value),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VetDetailScreen(
              vetId: vet.userId,
              profilePhotoUrl: vet.profilePhotoUrl,
            ),
          ),
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: 16.h),
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 78.w,
                    height: 78.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16.r),
                      image: vet.profilePhotoUrl != null
                          ? DecorationImage(
                              image: NetworkImage(vet.profilePhotoUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: vet.profilePhotoUrl == null
                        ? Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 34.sp,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vet.fullName,
                          style: TextStyle(
                            fontSize: 17.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${vet.degree} • ${vet.experience} yrs exp',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            if (vet.rating > 0)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFBBF24).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(999.r),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: const Color(0xFFF59E0B),
                                      size: 14.sp,
                                    ),
                                    SizedBox(width: 3.w),
                                    Text(
                                      vet.rating.toStringAsFixed(1),
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Theme.of(context).colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (vet.rating > 0) SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: vet.isAvailable
                                    ? Colors.green.withOpacity(0.16)
                                    : Theme.of(context).colorScheme.error.withOpacity(0.14),
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Text(
                                vet.isAvailable ? 'Available' : 'Busy',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: vet.isAvailable
                                      ? Colors.green
                                      : Theme.of(context).colorScheme.error,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  if (vet.specialization.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 7.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Text(
                          vet.specialization.first,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  if (vet.specialization.isNotEmpty) SizedBox(width: 10.w),
                  Text(
                    'PKR ${vet.consultationFee.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 20.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                    child: Text(
                      'View',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialSpecialization;
  final double? initialMinRating;
  final Function(String?, String?, double?) onApply;
  final VoidCallback onClear;

  const _FilterBottomSheet({
    this.initialCity,
    this.initialSpecialization,
    this.initialMinRating,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late TextEditingController _cityController;
  String? _selectedSpecialization;
  double _minRating = 0;

  final List<String> _specializations = [
    'General Practice',
    'Emergency Care',
    'Surgery',
    'Dermatology',
    'Cardiology',
    'Oncology',
    'Dentistry',
    'Orthopedics',
  ];

  @override
  void initState() {
    super.initState();
    _cityController = TextEditingController(text: widget.initialCity);
    _selectedSpecialization = widget.initialSpecialization;
    _minRating = widget.initialMinRating ?? 0;
  }

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            
            // Header
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Vets',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // City
                  Text(
                    'City',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextField(
                      controller: _cityController,
                      style: TextStyle(fontSize: 15.sp),
                      decoration: InputDecoration(
                        hintText: 'Enter city name',
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 15.sp,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Specialization
                  Text(
                    'Specialization',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: _specializations.map((spec) {
                      final isSelected = _selectedSpecialization == spec;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedSpecialization = isSelected ? null : spec;
                        }),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.surfaceContainer,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            spec,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24.h),

                  // Min Rating
                  Row(
                    children: [
                      Text(
                        'Minimum Rating',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFBBF24),
                            size: 18.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _minRating > 0 ? _minRating.toStringAsFixed(1) : 'Any',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      thumbColor: Theme.of(context).colorScheme.primary,
                      overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      trackHeight: 6.h,
                    ),
                    child: Slider(
                      value: _minRating,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      onChanged: (value) => setState(() => _minRating = value),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            widget.onClear();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: Text(
                                'Clear',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            widget.onApply(
                              _cityController.text.trim().isEmpty
                                  ? null
                                  : _cityController.text.trim(),
                              _selectedSpecialization,
                              _minRating > 0 ? _minRating : null,
                            );
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Center(
                              child: Text(
                                'Apply Filters',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


