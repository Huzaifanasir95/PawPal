import '../../data/models/community_hub_models.dart';

class AdoptionState {
  final bool isLoading;
  final bool isCreating;
  final bool isLoadingDetail;
  final List<AdoptionListing> listings;
  final AdoptionListing? selectedListing;
  final String? filterPetType;
  final String searchQuery;
  final String? error;

  const AdoptionState({
    this.isLoading = false,
    this.isCreating = false,
    this.isLoadingDetail = false,
    this.listings = const [],
    this.selectedListing,
    this.filterPetType,
    this.searchQuery = '',
    this.error,
  });

  List<AdoptionListing> get filteredListings {
    if (searchQuery.isEmpty) return listings;
    return listings.where((listing) {
      return listing.petName.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  AdoptionState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isLoadingDetail,
    List<AdoptionListing>? listings,
    AdoptionListing? selectedListing,
    String? filterPetType,
    String? searchQuery,
    String? error,
  }) {
    return AdoptionState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
      listings: listings ?? this.listings,
      selectedListing: selectedListing ?? this.selectedListing,
      filterPetType: filterPetType ?? this.filterPetType,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error,
    );
  }
}
