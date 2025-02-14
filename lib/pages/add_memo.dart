import 'package:flutter/material.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memo_program/services/memo_services.dart';
import 'package:memo_program/widgets/memo_widget.dart';
import 'dart:io';
import 'package:memo_program/styles/memo_style.dart';
import '../models/memo.dart';
import '../widgets/image_view.dart';

class NewDiaryPage extends StatefulWidget {
  final Memo? memo;

  const NewDiaryPage({super.key, required this.memo});

  @override
  _NewDiaryPageState createState() => _NewDiaryPageState();
}

class _NewDiaryPageState extends State<NewDiaryPage> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _images = [];
  bool _isCheck = false;
  bool _isEditing = true;
  String viewPic = '';
  bool isWindows = Platform.isWindows;

  @override
  void initState() {
    super.initState();
    if (widget.memo != null) {
      _titleController.text = widget.memo!.title;
      _controller.text = widget.memo!.content;
      _images = widget.memo!.images.map((path) => File(path)).toList();
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _images.add(File(image.path));
      });
    }
  }

  void _viewImage(String path) {
    setState(() {
      _isCheck = true;
      viewPic = path;
    });
  }

  void _closeImageViewer() {
    setState(() {
      _isCheck = false;
    });
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.length + _images.length <= 3) {
      setState(() {
        _images.addAll(pickedFiles.map((e) => File(e.path)));
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const MemoReminderPop(
              title: '提示', content: '最多只能选择3张图片', action: '确定');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: MemoStyle.memoBackGroundColor,
      body: _buildMainLayout(),
    );
  }

  Widget _buildMainLayout() {
    return Stack(
      children: [
        // 主内容卡片
        Positioned.fill(
          top: 50,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: MemoStyle.cardDecoration,
            child: Column(
              children: [
                _buildHeaderSection(),
                _buildTitleSection(),
                _buildContentSection(),
                _buildImageSection(),
                _buildBottomActions(),
              ],
            ),
          ),
        ),
        // 悬浮统计信息
        _buildFloatingCounters(),
        // 图片查看器
        if (_isCheck) _buildImageViewer(),
      ],
    );
  }

  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildEditToggle(),
              _buildSaveButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return InkWell(
      child: IconButton(
        icon: const MemoBackButton(),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildEditToggle() {
    return IconButton(
      icon: Icon(_isEditing ? Icons.menu_book : Icons.edit),
      onPressed: () => setState(() => _isEditing = !_isEditing),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 82,
      child: ElevatedButton(
        onPressed: () => CURDManager.saveMemo(
          context,
          _controller,
          _titleController,
          _images,
          widget.memo,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromRGBO(64, 185, 222, 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          '保存',
          maxLines: 1,
          style: MemoStyle.bodyTextStyle
              .copyWith(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          TextField(
            onChanged: (text) {
              setState(() {});
            },
            controller: _titleController,
            style: MemoStyle.titleTextStyle,
            maxLines: 1,
            maxLength: 12,
            decoration: InputDecoration(
              hintText: '标题',
              hintStyle: MemoStyle.bodyHintTextStyle,
              border: InputBorder.none,
              counterText: '',
            ),
          ),
          const Divider(height: 1, color: Color.fromRGBO(200, 200, 200, 1)),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: _isEditing
            ? TextField(
                onChanged: (text) {
                  setState(() {});
                },
                controller: _controller,
                maxLines: 11,
                style: MemoStyle.bodyTextStyle,
                decoration: InputDecoration(
                  hintText: '在此输入文字...',
                  hintStyle: MemoStyle.bodyHintTextStyle,
                  border: InputBorder.none,
                ),
              )
            : SingleChildScrollView(
                child: Text(
                _controller.text,
                maxLines: 11,
                style: MemoStyle.bodyTextStyle,
              )),
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        if (_images.isNotEmpty) _buildImageList(),
        const Divider(height: 1, color: Color.fromRGBO(200, 200, 200, 1)),
      ],
    );
  }

  Widget _buildImageList() {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
        itemBuilder: (context, index) => _buildImageItem(index),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => _viewImage(_images[index].path),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_images[index],
                  width: 95, height: 95, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => _removeImage(index),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!isWindows) _buildCameraButton(),
          if (_images.length < 3) _buildGalleryButton(),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return _buildIconButton(
      icon: 'lib/assets/camera.svg',
      label: '拍照上传',
      onTap: _takePicture,
    );
  }

  Widget _buildGalleryButton() {
    return _buildIconButton(
      icon: 'lib/assets/photos.svg',
      label: _images.isEmpty ? '上传照片' : '继续上传',
      onTap: _pickImages,
    );
  }

  Widget _buildIconButton(
      {required String icon,
      required String label,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          ImageIcon(Svg(icon), size: 24, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(label, style: MemoStyle.bodyHintTextStyle),
        ],
      ),
    );
  }

  Widget _buildFloatingCounters() {
    return Positioned(
      top: 140,
      right: 50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('${_titleController.text.length}/12',
              style: MemoStyle.bodyHintTextStyle),
          const SizedBox(height: 370),
          Text('字数:${_controller.text.length}',
              style: MemoStyle.bodyHintTextStyle),
        ],
      ),
    );
  }

  Widget _buildImageViewer() {
    return InkWell(
      onTap: _closeImageViewer,
      child: Container(
        color: const Color.fromRGBO(0, 0, 0, 0.25),
        child: Center(
          child: ImageViewerBuilder(path: viewPic),
        ),
      ),
    );
  }
}
