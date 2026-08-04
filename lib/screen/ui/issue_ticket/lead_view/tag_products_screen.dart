import 'package:digitalerp/utils/lead_app_bar.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:digitalerp/model/lead_tag_products_response_model.dart';
import 'package:digitalerp/model/main_group_tag_products_response_model.dart';
import 'package:digitalerp/utils/app_constant_new.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'controller/lead_management_controller.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemGridFilterScreen extends StatefulWidget {
  final List<TagProducts> preselectedItems;

  const ItemGridFilterScreen({Key? key, this.preselectedItems = const []}) : super(key: key);

  @override
  State<ItemGridFilterScreen> createState() => _ItemGridFilterScreenState();
}

class _ItemGridFilterScreenState extends State<ItemGridFilterScreen> {
  final LeadViewController controller = Get.put(LeadViewController());
  final TextEditingController _searchController = TextEditingController();

  bool _showTypeFilter = false;
  int? _currentSubGroupParentId;

  String? _selectedType;
  String? _selectedGroup;
  int? _selectedGroupId;
  int? _selectedSubGroupId;

  final List<TagProducts> _selectedItems = [];
  final Map<int, int> _itemQuantityMap = {};

  @override
  @override
  void initState() {
    super.initState();
    controller.leadTagProductsTypeList();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.tagProductsList.clear();
      controller.update();
      _selectedItems.addAll(widget.preselectedItems);

      for (var item in _selectedItems) {
        _itemQuantityMap[item.itemid ?? item.hashCode] = item.quantity ?? 0;
      }
    });
  }

  Future<void> _fetchMainGroupData() async {
    await controller.mainGroupTagProductsList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LeadViewController>(
      key: UniqueKey(),
      builder: (ctrl) {
        final filtered = ctrl.tagProductsList.where((item) {
          final matchesSearch =
              (item.itemname ?? "").toLowerCase().contains(_searchController.text.toLowerCase());
          return matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: LeadAppBar(
            title: 'ERP Items',
            subtitle: 'Tag products to this lead',
            onBack: () => Navigator.pop(context),
          ),
          body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                _buildSearchField(),
                if (_showTypeFilter) ...[
                  const SizedBox(height: 10),
                  _buildTypeChips(),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: ctrl.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ctrl.tagProductsList.isEmpty
                          ? const Center(child: Text("No items found"))
                          : _buildGrid(filtered),
                ),
              ],
            ),
          ),
          floatingActionButton: _selectedItems.isNotEmpty
              ? FloatingActionButton.extended(
                  backgroundColor: purpleColor,
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text("Save (${_selectedItems.length})", style: const TextStyle(color: Colors.white)),
                  onPressed: () {
                    for (final item in _selectedItems) {
                      log('id: ${item.itemid}, name: ${item.itemname}, '
                          'qty: ${item.quantity}, price: ${item.rate}');
                    }
                    Navigator.pop(context, List<TagProducts>.from(_selectedItems));
                  },
                )
              : null,
        );
      },
    );
  }

  Widget _buildSearchField() {
    return TextFormField(
      controller: _searchController,
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: newTextHint),
        suffixIcon: IconButton(
          icon: Icon(Icons.filter_list, color: newBlueColor),
          onPressed: () async {
            _selectedGroup = null;
            _selectedType = null;
            controller.selectedType = null;
            // controller.mainGroup.clear();
            controller.update();

            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await showDialog(
                context: context,
                builder: (dialogContext) => _buildFilterDialog(dialogContext),
              );
            });
          },
        ),
        hintText: 'Search ERP item...',
        hintStyle: GoogleFonts.poppins(color: newTextHint),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: newBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: newBorderColor),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildTypeChips() {
    return GetBuilder<LeadViewController>(builder: (controller) {
      final types = ['main group'];
      return Wrap(
        spacing: 8,
        children: types.map((type) {
          return ChoiceChip(
            label: Text(type,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: controller.selectedType == type ? Colors.white : Colors.grey,
                )),
            selected: controller.selectedType == type,
            selectedColor: newBlueColor,
            backgroundColor: newSurfaceColor,
            onSelected: (_) async {
              if (controller.selectedType != type) {
                controller.selectedType = type;

                if (controller.mainGroup.isEmpty) {
                  await controller.mainGroupTagProductsList();
                }
              } else {
                controller.selectedType = null;
              }
              log('controller.selectedType = ${controller.selectedType}');
              controller.update();
            },
          );
        }).toList(),
      );
    });
  }

  Widget _buildGroupList() {
    return GetBuilder<LeadViewController>(
      builder: (ctrl) {
        if (ctrl.isLoading) return const Center(child: CircularProgressIndicator());
        if (ctrl.mainGroup.isEmpty) return const Center(child: Text("No groups found"));

        final TextEditingController searchController = TextEditingController();

        return StatefulBuilder(builder: (context, setStateSearch) {
          List<MainGroup> filteredGroups = ctrl.mainGroup.where((group) {
            final name = group.categoryname ?? "";
            return name.toLowerCase().contains(searchController.text.toLowerCase());
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search group...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) => setStateSearch(() {}),
              ),
              const SizedBox(height: 12),
              if (filteredGroups.isEmpty)
                const Center(child: Text("No matching categories"))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredGroups.length,
                  itemBuilder: (context, index) {
                    final group = filteredGroups[index];
                    final isExpanded = _selectedGroupId == group.categoryid;
                    final subGroups = ctrl.subGroupsMap[group.categoryid] ?? [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.category, color: purpleColor),
                          title: Text(group.categoryname ?? ""),
                          tileColor:
                              _selectedGroupId == group.categoryid ? purpleColor.withOpacity(0.1) : null,
                          // onTap: () async {
                          //   final isSameGroup = _selectedGroupId == group.categoryid;
                          //
                          //   if (!isSameGroup && !ctrl.subGroupsMap.containsKey(group.categoryid)) {
                          //     await ctrl.subGroupTagProductsList(id: group.categoryid);
                          //   }
                          //
                          //   setStateSearch(() {
                          //     if (_selectedGroupId == group.categoryid) {
                          //       _selectedGroupId = null;
                          //       _selectedGroup = null;
                          //       _selectedSubGroupId = null;
                          //     } else {
                          //       _selectedGroupId = group.categoryid;
                          //       _selectedGroup = group.categoryname;
                          //
                          //       _selectedSubGroupId = null;
                          //     }
                          //   });
                          // },
                          onTap: () {
                            final isSameGroup = _selectedGroupId == group.categoryid;

                            if (!isSameGroup && !ctrl.subGroupsMap.containsKey(group.categoryid)) {
                              // async fetch but don't call setStateSearch in StatefulBuilder
                              ctrl.subGroupTagProductsList(id: group.categoryid).then((_) {
                                // instead, update the parent state if dialog still open
                                if (!mounted) return;
                                setState(() {
                                  _selectedGroupId = group.categoryid;
                                  _selectedGroup = group.categoryname;
                                  _selectedSubGroupId = null;
                                });
                                // optional: tell controller to rebuild if needed
                                ctrl.update();
                              });
                            } else {
                              // can safely update parent state
                              setState(() {
                                if (_selectedGroupId == group.categoryid) {
                                  _selectedGroupId = null;
                                  _selectedGroup = null;
                                  _selectedSubGroupId = null;
                                } else {
                                  _selectedGroupId = group.categoryid;
                                  _selectedGroup = group.categoryname;
                                  _selectedSubGroupId = null;
                                }
                              });
                              ctrl.update();
                            }
                          },
                        ),
                        if (isExpanded && subGroups.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 32.0, bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Sub Groups:",
                                    style: GoogleFonts.poppins(
                                        color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                ...subGroups.map((sub) {
                                  final isSelected = _selectedSubGroupId == sub.subcategoryid;
                                  return InkWell(
                                    onTap: () {
                                      setStateSearch(() {
                                        if (isSelected) {
                                          // Unselect if already selected
                                          _selectedSubGroupId = null;
                                        } else {
                                          // Select new subgroup
                                          _selectedSubGroupId = sub.subcategoryid;
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSelected ? purpleColor.withOpacity(0.1) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            isSelected ? Icons.check_circle : Icons.arrow_right,
                                            color: purpleColor,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            sub.subcategoryname ?? "",
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: isSelected ? purpleColor : Colors.grey[800],
                                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
            ],
          );
        });
      },
    );
  }

  Widget _buildGrid(List<TagProducts> items) {
    return GridView.builder(
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 2.95,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                radius: 28,
                child: (item.itemimage == null || item.itemimage!.isEmpty)
                    ? const Icon(Icons.image_not_supported, size: 28, color: Colors.grey)
                    : Image.network(item.itemimage!, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.category, size: 30, color: purpleColor);
                      }),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(item.itemname ?? "",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 15, color: purpleColor)),
                    ),
                    Text(item.itemcode ?? "", style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text('₹${item.rate ?? 0}',
                            style: GoogleFonts.poppins(
                                fontSize: 14, fontWeight: FontWeight.w500, color: Colors.green)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              final current = _itemQuantityMap[item.itemid ?? item.hashCode] ?? 0;
                              if (current > 0) {
                                _itemQuantityMap[item.itemid ?? item.hashCode] = current - 1;
                                if ((_itemQuantityMap[item.itemid ?? item.hashCode] ?? 0) > 0) {
                                  if (!_selectedItems.contains(item)) {
                                    _selectedItems.add(item);
                                  }
                                  item.quantity = _itemQuantityMap[item.itemid ?? item.hashCode]!;
                                } else {
                                  _selectedItems.removeWhere((x) => x.itemid == item.itemid);
                                  item.quantity = 0;
                                }
                              }
                            });
                          },
                        ),
                        Text(
                          (_itemQuantityMap[item.itemid ?? item.hashCode] ?? 0).toString(),
                          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              final current = _itemQuantityMap[item.itemid ?? item.hashCode] ?? 0;
                              _itemQuantityMap[item.itemid ?? item.hashCode] = current + 1;
                              if (!_selectedItems.contains(item)) {
                                _selectedItems.add(item);
                              }
                              item.quantity = _itemQuantityMap[item.itemid ?? item.hashCode]!;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterDialog(BuildContext context) {
    return GetBuilder<LeadViewController>(
      builder: (controller) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          title: Text(
            "Filter Items",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 20,
              color: purpleColor,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Type", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildTypeChips(),
                  const SizedBox(height: 20),
                  Text("Select Group", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildGroupList(),
                ],
              ),
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      // Clear filter
                      _selectedGroupId = null;
                      _selectedSubGroupId = null;
                      _selectedGroup = null;
                      _selectedType = null;
                      controller.selectedType = null;
                      controller.mainGroup.clear();
                      controller.update();
                      await controller.leadTagProductsTypeList();
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Clear Filter",
                      style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purpleColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);

                      // No selection: fetch all items
                      if (_selectedGroupId == null && _selectedSubGroupId == null) {
                        await controller.leadTagProductsTypeList();
                        controller.update();
                        return;
                      }

                      // Only main group selected: fetch items filtered by main group
                      if (_selectedGroupId != null && _selectedSubGroupId == null) {
                        await controller.leadTagProductsTypeList(
                          categoryId: _selectedGroupId.toString(),
                        );
                        controller.update();
                        return;
                      }

                      // Both main group and subgroup selected
                      if (_selectedGroupId != null && _selectedSubGroupId != null) {
                        await controller.leadTagProductsTypeList(
                          categoryId: _selectedGroupId.toString(),
                          subCategoryId: _selectedSubGroupId.toString(),
                        );
                        controller.update();
                      }
                    },
                    child: const Text("Apply",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
