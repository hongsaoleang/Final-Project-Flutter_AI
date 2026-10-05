import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/user_location_service.dart';

class SelectLivingPlaceDialog extends StatefulWidget {
  final Function(String country, String city, LatLng coordinates, String? address) onLocationSelected;

  const SelectLivingPlaceDialog({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<SelectLivingPlaceDialog> createState() => _SelectLivingPlaceDialogState();
}

class _SelectLivingPlaceDialogState extends State<SelectLivingPlaceDialog> {
  final UserLocationService _locService = UserLocationService();
  final TextEditingController _customAddressController = TextEditingController();

  late String _selectedCountry;
  late String _selectedCity;
  bool _isSearchingCustom = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _locService.country;
    _selectedCity = _locService.city;
  }

  CountryInfo get _currentCountryInfo {
    return UserLocationService.supportedCountries.firstWhere(
      (c) => c.name.toLowerCase() == _selectedCountry.toLowerCase(),
      orElse: () => UserLocationService.supportedCountries.first,
    );
  }

  CityInfo get _currentCityInfo {
    final country = _currentCountryInfo;
    return country.cities.firstWhere(
      (c) => c.name.toLowerCase() == _selectedCity.toLowerCase(),
      orElse: () => country.cities.first,
    );
  }

  Future<void> _handleSave() async {
    if (_customAddressController.text.trim().isNotEmpty) {
      setState(() => _isSearchingCustom = true);
      final customQuery = _customAddressController.text.trim();
      final success = await _locService.setCustomLocation(customQuery);
      if (mounted) {
        setState(() => _isSearchingCustom = false);
        if (success) {
          widget.onLocationSelected(
            _locService.country,
            _locService.city,
            _locService.livingPlace.coordinates,
            customQuery,
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not find "$customQuery". Try a recognized city or landmark.')),
          );
        }
      }
      return;
    }

    final cityInfo = _currentCityInfo;
    final specificAddress = _customAddressController.text.trim();
    _locService.setLivingPlace(
      country: _selectedCountry,
      city: _selectedCity,
      coordinates: cityInfo.coordinates,
      specificAddress: specificAddress.isNotEmpty ? specificAddress : null,
    );

    widget.onLocationSelected(
      _selectedCountry,
      _selectedCity,
      cityInfo.coordinates,
      specificAddress.isNotEmpty ? specificAddress : null,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final countryInfo = _currentCountryInfo;

    return Dialog(
      backgroundColor: AppTheme.cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.home, color: AppTheme.primaryLight, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set Where You Live',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'AI will use this as your default departure place',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 28),

              // Country Selector
              const Text('Select Country', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: countryInfo.name,
                    dropdownColor: AppTheme.cardDark,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryLight),
                    items: UserLocationService.supportedCountries.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.name,
                        child: Row(
                          children: [
                            Text(c.flag, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            Text(c.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCountry = val;
                          final newCountry = UserLocationService.supportedCountries.firstWhere((c) => c.name == val);
                          _selectedCity = newCountry.cities.first.name;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // City Selector
              const Text('Select City', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: countryInfo.cities.any((c) => c.name == _selectedCity) ? _selectedCity : countryInfo.cities.first.name,
                    dropdownColor: AppTheme.cardDark,
                    isExpanded: true,
                    icon: const Icon(Icons.location_city, color: AppTheme.primaryLight),
                    items: countryInfo.cities.map((ci) {
                      return DropdownMenuItem<String>(
                        value: ci.name,
                        child: Text(ci.name, style: const TextStyle(color: Colors.white, fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedCity = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Specific Address / Neighborhood
              const Text('Specific Neighborhood / Address (Optional)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _customAddressController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g., Riverside, BKK1, Downtown, Street 2004',
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                  filled: true,
                  fillColor: AppTheme.surfaceDark,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.pin_drop, color: AppTheme.primaryLight, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: _isSearchingCustom
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check, size: 18),
                    label: const Text('Set as Living Place'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSearchingCustom ? null : _handleSave,
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
