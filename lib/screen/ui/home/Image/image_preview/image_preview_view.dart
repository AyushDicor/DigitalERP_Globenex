import 'package:digitalerp/response/stcok_category_data_response.dart';
// base_controller provides the `.bold` TextStyle extension used by the
// watermark overlay below.
import 'package:digitalerp/screen/base/base_controller.dart';
import 'package:digitalerp/screen/ui/home/Image/image_controller.dart';
import 'package:digitalerp/screen/ui/home/Image/image_preview/image_preview_controller.dart';
// NOTE: this app's app_constant.dart already defines the new design tokens
// (newBlueColor / newTextPrimary / newTextSecondary / newTextHint /
// newBorderColor), so importing app_constant_new here too would make every
// one of those names ambiguous. Deliberately using app_constant only.
import 'package:digitalerp/utils/app_constant.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImagePreviewView extends StatelessWidget {
  const ImagePreviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImagePreviewController>(
      init: ImagePreviewController(
          ModalRoute.of(context)!.settings.arguments as ImagePreviewArgument,
          context),
      builder: (controller) => Scaffold(
        backgroundColor: const Color(0xFFF5F6FA),
        body: SafeArea(
          child: Column(
            children: [
              _appBar(controller),
              Expanded(
                child: controller.isBusy
                    ? const Center(
                        child: CircularProgressIndicator(color: newBlueColor))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            card(controller),
                            const SizedBox(height: 24),
                            _label('Group'),
                            const SizedBox(height: 8),
                            _groupDropdown(controller),
                            const SizedBox(height: 18),
                            _label('Title'),
                            const SizedBox(height: 8),
                            _textField(
                              controller: controller.titleController,
                              focusNode: controller.titleFocus,
                              hint: 'Enter Title',
                            ),
                            const SizedBox(height: 18),
                            _label('Description'),
                            const SizedBox(height: 8),
                            _textField(
                              controller: controller.descriptionController,
                              focusNode: controller.descriptionFocus,
                              hint: 'Enter Description',
                              maxLines: 5,
                            ),
                          ],
                        ),
                      ),
              ),
              _saveBar(controller),
            ],
          ),
        ),
      ),
    );
  }

  //  Flat white app bar (replaces the old full-screen Stack + background
  //  image layout, which stretched the app bar over the whole page and left
  //  its title floating in the middle of the screen).
  Widget _appBar(ImagePreviewController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.backTap(),
            child: const Icon(Icons.arrow_back_ios_new,
                color: newTextPrimary, size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('Image Preview',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: newTextPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: newTextPrimary));

  //  IMPORTANT: the internals of this card are deliberately unchanged.
  //  `makeImage()` captures ONLY the RepaintBoundary (the LAT/LON/ADD block)
  //  as a stamp, and `makeImage2()` then composites that stamp onto the
  //  original photo at dstX:0, dstY:0. Changing the overlay's size, padding
  //  or position would move the watermark on the saved image.
  Widget card(ImagePreviewController controller) => Stack(
        children: [
          Container(
            height: 200,
            width: double.maxFinite,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12, blurRadius: 3, offset: Offset(0, 5))
                ]),
            margin: const EdgeInsets.only(bottom: 10),
            clipBehavior: Clip.antiAlias,
            child: Image.file(
              controller.captureImage.file,
              fit: BoxFit.cover,
            ),
          ),
          RepaintBoundary(
            key: controller.globalKey,
            child: SizedBox(
              height: 200,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LAT - ${controller.captureImage.lat}',
                            style: const TextStyle()
                                .bold
                                .copyWith(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'LON - ${controller.captureImage.long}',
                            style: const TextStyle()
                                .bold
                                .copyWith(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'ADD - ${controller.captureImage.location}',
                            style: const TextStyle()
                                .bold
                                .copyWith(fontSize: 12, color: Colors.white),
                          ),
                          const SizedBox(height: 3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      );

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      minLines: maxLines,
      maxLines: maxLines,
      keyboardType:
          maxLines > 1 ? TextInputType.multiline : TextInputType.text,
      textInputAction:
          maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
      style: const TextStyle(fontSize: 14, color: newTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: newTextHint),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: newBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: newBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: newBlueColor, width: 1.4),
        ),
      ),
    );
  }

  //  NOTE: dropdown_button2 here is v1.9.4 — the OLD API
  //  (buttonHeight / buttonPadding / buttonDecoration / dropdownDecoration).
  //  The newer buttonStyleData API does not compile against this version.
  Widget _groupDropdown(ImagePreviewController controller) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<StockCategoryList>(
        isExpanded: true,
        buttonHeight: 52,
        buttonPadding: const EdgeInsets.symmetric(horizontal: 14),
        buttonDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: newBorderColor),
        ),
        dropdownDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          border: Border.all(color: newBorderColor),
        ),
        dropdownMaxHeight: 240,
        hint: const Text('Select Group',
            style: TextStyle(fontSize: 14, color: newTextHint)),
        value: controller.selectedGroupDropdownValue,
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: newTextSecondary, size: 22),
        items: controller.groupList?.map((StockCategoryList value) {
          return DropdownMenuItem(
            value: value,
            child: Text(value.categoryname.toString(),
                style: const TextStyle(fontSize: 14, color: newTextPrimary),
                overflow: TextOverflow.ellipsis),
          );
        }).toList(),
        onChanged: controller.setSelectGroup,
      ),
    );
  }

  Widget _saveBar(ImagePreviewController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () => controller.onTapSave(),
          style: ElevatedButton.styleFrom(
            backgroundColor: newBlueColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Save',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
