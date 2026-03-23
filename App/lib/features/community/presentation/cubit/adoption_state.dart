import '../../data/models/community_hub_models.dart';

class AdoptionState {
  final bool isLoading;
  final bool isCreating;
  final bool isLoadingDetail;
  final List<AdoptionListing> listings;
  final AdoptionListing? selectedListing;
  final String? filterPetType;
  final String? error;

  const AdoptionState({
    this.isLoading = false,
    this.isCreating = false,
    this.isLoadingDetail = false,
    this.listings = const [],
    this.selectedListing,
    this.filterPetType,
    this.error,
  });

  AdoptionState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isLoadingDetail,
    List<AdoptionListing>? listings,
    AdoptionListing? selectedListing,
    String? filterPetType,
    String? error,
  }) {
    return AdoptionState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      listings: listings ?? this.listings,
      selectedListing: selectedListing ?? this.selectedListing,
      filterPetType: filterPetType ?? this.filterPetType,
      error: error,
    );
  }
}
