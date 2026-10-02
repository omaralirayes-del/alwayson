import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // قم باستبدال البيانات برابط مشروعك والـ anonKey
  await Supabase.initialize(
    url: 'https://jgrojlmylrpziimwcybx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impncm9qbG15bHJwemlpbXdjeWJ4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA5MzQ4NjAsImV4cCI6MjEwNjUxMDg2MH0.OXPKaPLGPQAcQyI1HIwAlQqWhFB3hxojWY-Utm9kw0k',
  );

  runApp(const MyApp());
}
Future<void> openWhatsApp() async {
  // استبدل الرقم برقم هاتفك مع رمز الدولة (بدون علامة + أو مسافات)، مثلاً: 201234567890+
  final String phoneNumber = '201020431653'; 
  final String message = 'مرحباً، أود الاستفسار عن...'; // رسالة جاهزة اختيارية
  
  final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

  if (await canLaunchUrl(whatsappUrl)) {
    await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
  } else {
    throw 'تعذر فتح الواتساب';
  }
}

// دالة جلب معرّف الجهاز الفريد لتميز صاحب البوست
Future<String> getDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id.trim();
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return (iosInfo.identifierForVendor ?? 'unknown_ios').trim();
    } else if (Platform.isLinux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return (linuxInfo.machineId ?? linuxInfo.id).trim();
    }
  } catch (e) {
    print('Error getting device ID: $e');
  }
  return 'default_device_id';
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "font"),
      home: const CustomAnimatedSplash(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final supabase = Supabase.instance.client;

  // جلب المنشورات من Supabase
  Future<List<Map<String, dynamic>>> fetchPosts() async {
    final response = await supabase
        .from('posts')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // دالة الحذف
  Future<void> _deletePost(String postId) async {
    try {
      final myDeviceId = await getDeviceId();

      await supabase
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('device_id', myDeviceId);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم حذف المنشور بنجاح')));
        setState(() {}); // إعادة بناء الشاشة لتحديث القائمة فوراً
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('حدث خطأ أثناء الحذف: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        
        title: Text("AlwaysOn",style: TextStyle(color: const Color.fromARGB(255, 185, 150, 21)),),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(0, 95, 83, 83),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.amber,),
      ),
      drawer: Drawer(
        
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/drawer.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 30),
              MaterialButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: ((context) => CreatePostScreen()),
                    ),
                  );
                  setState(() {});
                },
                child: Container(
                  width: double.infinity,
                  child: Card(
                    child: ListTile(
                      leading: Text(
                        "Create a Post",
                        style: TextStyle(
                          color: const Color.fromARGB(255, 214, 168, 3),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Icon(
                        Icons.post_add,
                        color: const Color.fromARGB(255, 214, 168, 3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              Text("Omar Rayes تم تطويره بواسطة",style: TextStyle(color: const Color.fromARGB(255, 143, 109, 6),fontSize: 16,fontWeight: FontWeight.w500),),
            Center(
              child: ElevatedButton.icon(
                onPressed: openWhatsApp,
                icon: Icon(Icons.chat, color: Colors.green), // يمكنك وضع أيقونة واتساب إذا كانت متوفرة لديك
                label: Text('تواصل معي عبر واتساب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}'));
          }

          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/main.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  '....لا توجد منشورات ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("images/main.jpeg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return PostCard(
                    post: post,
                    onDelete: () => _deletePost(post['id'].toString()),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// كارت عرض البوست مع التحقق من المالك
class PostCard extends StatefulWidget {
  final Map<String, dynamic> post;
  final Future<void> Function() onDelete;

  const PostCard({super.key, required this.post, required this.onDelete});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isMyPost = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
  }

  void _checkOwnership() async {
    final currentDeviceId = await getDeviceId();
    final postDeviceId = widget.post['device_id']?.toString().trim();

    if (mounted && postDeviceId != null && postDeviceId == currentDeviceId) {
      setState(() {
        isMyPost = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.post['title'] ?? '';
    final String description = widget.post['description'] ?? '';
    final String imageUrl = widget.post['image_url'] ?? '';
    final String postId = widget.post['id'].toString();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack لوضع زر الحذف فوق الصورة في الزاوية العلوية
          Stack(
            children: [
              if (imageUrl.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ImageDetailScreen(imageUrl: imageUrl, tag: postId),
                      ),
                    );
                  },
                  child: Hero(
                    tag: postId,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 250,
                        color: Colors.grey[850],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                ),

              // زر الحذف في الزاوية العلوية اليمنى للصورة
              if (isMyPost)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.6,
                      ), // خلفية دائرية معتمة لوضوح الزر
                      shape: BoxShape.circle,
                    ),
                    child: isDeleting
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 22,
                            ),
                            onPressed: () async {
                              // إظهار رسالة التاكد عند الضغط على زر الحذف
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('تأكيد الحذف'),
                                  content: const Text(
                                    'هل أنت تأكد من أنك تريد حذف هذا المنشور؟',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('إلغاء'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'حذف',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              // إذا اضغط على "حذف" يتم تنفيذ الحذف
                              if (confirm == true) {
                                setState(() => isDeleting = true);
                                await widget.onDelete();
                              }
                            },
                          ),
                  ),
                ),
            ],
          ),

          // تفاصيل المنشور
          if (title.isNotEmpty || description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// شاشة العرض الكامل مع زوم الواتساب
class ImageDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String tag;

  const ImageDetailScreen({
    super.key,
    required this.imageUrl,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          ),
        ),
      ),
    );
  }
}

// شاشة اختيار ورفع الصورة
class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // اختيار الصورة مع ضغط الحجم والأبعاد
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50, // ضغط الجودة للنصف
      maxWidth: 1080, // تحديد أقصى أبعاد للصورة
      maxHeight: 1080,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // الرفع عند الضغط على زر الرفع فقط
  Future<void> _uploadPost() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);

    try {
      final supabase = Supabase.instance.client;
      final String myDeviceId = await getDeviceId();

      // طباعة للتأكد قبل الإرسال
      print('*** SENDING DEVICE ID: $myDeviceId ***');

      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final path = 'public/$fileName';

      await supabase.storage.from('images').upload(path, _selectedImage!);
      final String imageUrl = supabase.storage
          .from('images')
          .getPublicUrl(path);

      final response = await supabase.from('posts').insert({
        'title': _titleController.text,
        'description': _descController.text,
        'image_url': imageUrl,
        'device_id': myDeviceId,
      }).select(); // .select() ترجع لك السطر المضاف فوراً للتأكد

      print('*** INSERT RESPONSE: $response ***');

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('تم نشر البوست بنجاح!')));
        Navigator.pop(context);
      }
    } catch (e) {
      print('*** ERROR IN UPLOAD: $e ***');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: const Color.fromARGB(31, 197, 189, 189),title: const Text('إضافة منشور جديد'),),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/post.jpeg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[700]!),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 50,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text('اضغط هنا لاختيار صورة'),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                
                style: TextStyle(color: Colors.black),
                controller: _titleController,
                decoration: const InputDecoration(
                  fillColor: Color.fromARGB(255, 117, 113, 113),
                  filled: true,
                  hintText: 'العنوان',
                  hintStyle: TextStyle(color: Color.fromARGB(255, 160, 156, 156)),
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                style: TextStyle(color: Colors.black),

                controller: _descController,
                decoration: const InputDecoration(
                  hintText: 'الوصف',
                fillColor: Color.fromARGB(255, 117, 113, 113),
                  filled: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              _isUploading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _uploadPost,
                      icon: const Icon(Icons.cloud_upload,color: Colors.black),
                      label: const Text('رفع المنشور',style: TextStyle(color: Colors.black),),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAnimatedSplash extends StatefulWidget {
  const CustomAnimatedSplash({super.key});

  @override
  State<CustomAnimatedSplash> createState() => _CustomAnimatedSplashState();
}

class _CustomAnimatedSplashState extends State<CustomAnimatedSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

 
  @override
  void initState() {
  
    super.initState();

    // إعداد التحكم في وقت الحركة (ثانيتين)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // حركة التكبير والتصغير الفاخرة (Scale)
    _scaleAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // حركة الظهور التدريجي (Fade)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // بدء الحركة
    _controller.forward();

    // الانتقال للشاشة الرئيسية بعد انتهاء الحركة
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    });
  }

  

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E), // خلفية سوداء فاخرة
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // هنا تضع صورة أيقونة تطبيقك الخاصة
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37)
                                .withOpacity(0.3), // توهج ذهبي خلف الأيقونة
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'images/icon.jpg', // مسار أيقونة تطبيقك
                        width: 140,
                        height: 140,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'AlwaysOn',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
