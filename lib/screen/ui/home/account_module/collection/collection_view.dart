import 'dart:convert';
import 'dart:io';

import 'package:digitalerp/response/cash_bank_ledger_response.dart';
import 'package:digitalerp/response/collection_customer_list_response.dart';
import 'package:digitalerp/screen/ui/fab/menu_fab.dart';
import 'package:digitalerp/screen/ui/home/account_module/collection/collection_controller.dart';
import 'package:digitalerp/utils/app_constant_new.dart'
    show
        AppString,
        newTextPrimary,
        newTextSecondary,
        newTextHint,
        newBorderColor,
        newSurfaceColor,
        newBlueColor,
        newBlueLightColor;
import 'package:digitalerp/utils/app_loader.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CollectionView extends StatelessWidget {
  const CollectionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CollectionController>(
      init: CollectionController(),
      builder: (controller) => Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: newSurfaceColor,
        body: SafeArea(
          child: Column(
            children: [
              _appBar(controller),
              Expanded(
                child: controller.isBusy
                    ? const AppLoader()
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionLabel('Customer'),
                            const SizedBox(height: 8),
                            controller.argument == null
                                ? _customerDropdown(controller)
                                : Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: newBorderColor),
                                    ),
                                    child: Text(
                                      controller.customerName,
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: newTextPrimary),
                                    ),
                                  ),
                            const SizedBox(height: 16),
                            _sectionLabel('Select Date'),
                            const SizedBox(height: 8),
                            _dateField(context, controller),
                            const SizedBox(height: 16),
                            _sectionLabel(AppString.amount),
                            const SizedBox(height: 8),
                            _boxField(
                              controller: controller.amountController,
                              focusNode: controller.amountFocus,
                              hint: AppString.enterAmount,
                              maxLength: 6,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            ),
                            const SizedBox(height: 16),
                            _sectionLabel(AppString.paymentMode),
                            const SizedBox(height: 8),
                            ...List.generate(
                              controller.paymentOptionList.length,
                              (index) => _paymentCard(controller, index, context),
                            ),
                            const SizedBox(height: 8),
                            _sectionLabel(AppString.selectCollectionLedger),
                            const SizedBox(height: 8),
                            _ledgerDropdown(controller),
                            const SizedBox(height: 16),
                            _sectionLabel(AppString.remark),
                            const SizedBox(height: 8),
                            _boxField(
                              controller: controller.remarkController,
                              focusNode: controller.remarkFocus,
                              hint: AppString.type,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            _imageUploadSection(controller),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => controller.tapOnSubmit(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: newBlueColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: MenuFab(parentMenuId: 2382),
      ),
    );
  }

  Widget _appBar(CollectionController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => controller.backTap(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: newTextPrimary, size: 20),
          ),
          Text(
            'Collection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: newTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: newTextSecondary),
    );
  }

  Widget _dateField(BuildContext context, CollectionController controller) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => controller.tapOnDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: newBorderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              controller.selectDate,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: newTextPrimary),
            ),
            Icon(Icons.calendar_today_rounded, size: 16, color: newBlueColor),
          ],
        ),
      ),
    );
  }

  Widget _boxField({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    int maxLines = 1,
    int? maxLength,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: newBorderColor),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        maxLength: maxLength,
        keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        inputFormatters: inputFormatters,
        style: TextStyle(fontSize: 14, color: newTextPrimary),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: newTextHint),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _paymentCard(CollectionController controller, int index, BuildContext context) {
    final bool selected = controller.selectedIndex == index;
    final bool isCheque = index == 1;
    return GestureDetector(
      onTap: () => controller.setSelectedIndex(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? newBlueColor : newBorderColor, width: selected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.paymentOptionList[index],
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: newTextPrimary),
                ),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected ? newBlueColor : newTextHint,
                  size: 22,
                ),
              ],
            ),
            if (selected && isCheque) ...[
              const SizedBox(height: 12),
              _boxField(
                controller: controller.chequeNoController,
                hint: 'Cheque No.',
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 10),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => controller.tapOnChequeDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: newBorderColor),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        controller.selectChequeDate,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: newTextSecondary),
                      ),
                      Icon(Icons.calendar_today_rounded, size: 16, color: newBlueColor),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _customerDropdown(CollectionController controller) {
    return _styledDropdown<CustomerData>(
      value: controller.selectedDropdownValue,
      hint: AppString.selectCustomer,
      items: controller.customerDataList
          .map((e) => DropdownMenuItem<CustomerData>(
                value: e,
                child: Text(
                  e.partyname.toString(),
                  style: TextStyle(fontSize: 14, color: newTextPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (newValue) => controller.setDropdownValue(newValue),
    );
  }

  Widget _ledgerDropdown(CollectionController controller) {
    return _styledDropdown<CashAndBankLedgerDataList>(
      value: controller.selectedCollectionLedgerValue,
      hint: AppString.selectCollectionLedger,
      items: controller.cashAndBankLedgerList
          .map((e) => DropdownMenuItem<CashAndBankLedgerDataList>(
                value: e,
                child: Text(
                  e.partyname.toString(),
                  style: TextStyle(fontSize: 14, color: newTextPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      onChanged: (newValue) => controller.setCashAndBankLedgerDropdownValue(newValue),
    );
  }

  Widget _styledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<T>(
        isExpanded: true,
        buttonHeight: 50,
        buttonPadding: const EdgeInsets.symmetric(horizontal: 16),
        buttonDecoration: BoxDecoration(
          color: const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: newBorderColor),
        ),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          border: Border.all(color: newBorderColor),
        ),
        dropdownMaxHeight: 220,
        value: value,
        hint: Text(
          hint,
          style: TextStyle(fontSize: 14, color: newTextHint),
          overflow: TextOverflow.ellipsis,
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: newTextSecondary, size: 22),
        items: items,
        onChanged: onChanged,
      ),
    );
  }

  Widget _imageUploadSection(CollectionController controller) {
    final bool hasImage = controller.selectedImage.value != '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Attachment'),
        const SizedBox(height: 8),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showImageDialog(controller),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: newBorderColor),
            ),
            padding: EdgeInsets.symmetric(vertical: hasImage ? 0 : 28),
            alignment: Alignment.center,
            child: hasImage
                ? Image.file(
                    File(controller.selectedImage.value),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: newBlueLightColor, borderRadius: BorderRadius.circular(50)),
                        child: Icon(Icons.cloud_upload_outlined, color: newBlueColor, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload picture',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: newBlueColor),
                      ),
                    ],
                  ),
          ),
        ),
        if (hasImage) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () => _showImageDialog(controller),
              child: Text(
                'Change image',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: newBlueColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  _showImageDialog(CollectionController value) {
    return Get.defaultDialog(
      title: AppString.chooseOption,
      radius: 8,
      titleStyle: TextStyle(color: newTextPrimary, fontWeight: FontWeight.w700),
      content: Column(
        children: [
          InkWell(
            onTap: () {
              _getImage(ImageSource.gallery, value);
            },
            child: Text(
              AppString.selectImageFromGallery,
              style: TextStyle(color: newTextPrimary),
            ),
          ),
          SizedBox(height: Get.height * .02),
          InkWell(
            onTap: () {
              _getImage(ImageSource.camera, value);
            },
            child: Text(
              AppString.takePicture,
              style: TextStyle(color: newTextPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _getImage(ImageSource source, CollectionController value) async {
    Get.back();
    var pickedFile = await value.picker.pickImage(
      source: source,
      imageQuality: 65,
    );
    if (pickedFile != null) {
      var file = File(pickedFile.path);
      value.selectedImageBase64.value = base64.encode(file.readAsBytesSync());
      value.selectedImageFileName.value = file.path.split('/').last;
      value.setSelectedImage(file.path);
    }
  }
}
