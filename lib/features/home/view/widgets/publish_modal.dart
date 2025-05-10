import 'package:flutter/material.dart';
import '../../../../features/article/view/create_article_view.dart';

class PublishModal extends StatelessWidget {
  const PublishModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          // Kapat çizgisi
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Yeni makale butonu
          _buildOptionButton(
            context: context,
            icon: Icons.article_outlined,
            label: 'Yeni makale',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateArticleView(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // İş ilanı ver butonu
          _buildOptionButton(
            context: context,
            icon: Icons.work_outline,
            label: 'İş ilanı ver',
            onTap: () {
              Navigator.pop(context);
              // TODO: İş ilanı sayfasına yönlendir
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
