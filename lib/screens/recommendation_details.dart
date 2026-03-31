import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationDetailsScreen extends StatelessWidget {
  final String category;

  const RecommendationDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> items = _getItemsForCategory(category);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5), // Lavender background
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF3E5F5), // Lavender
              Color(0xFFFCE4EC), // Baby Pink
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4A148C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  category,
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4A148C),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      onTap: () async {
                        if (item.containsKey('url') && item['url']!.isNotEmpty) {
                          final url = Uri.parse(item['url']!);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              _getCategoryIcon(category),
                              color: _getCategoryColor(category),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  item['subtitle']!,
                                  style: GoogleFonts.lato(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, String>> _getItemsForCategory(String category) {
    if (category == "Uplifting Songs") {
      return [
        {"title": "Dil Lagana Mana Tha", "subtitle": "Bollywood", "url": "https://www.youtube.com/results?search_query=dil+lagana+mana+tha+song"},
        {"title": "Coming For You", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=coming+for+you+song"},
        {"title": "You Are The Sun In My Life", "subtitle": "Classic", "url": "https://www.youtube.com/results?search_query=you+are+the+sun+in+my+life+song"},
        {"title": "End Of Beginning", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=end+of+beginning+song"},
        {"title": "Good Goodbye", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=good+goodbye+song"},
        {"title": "Guzaarishein", "subtitle": "Bollywood", "url": "https://www.youtube.com/results?search_query=guzaarishein+song"},
        {"title": "Chahun Main Ya Naa", "subtitle": "Bollywood", "url": "https://www.youtube.com/results?search_query=chahun+main+ya+naa+song"},
        {"title": "Khairiyat", "subtitle": "Bollywood", "url": "https://www.youtube.com/results?search_query=khairiyat+song"},
        {"title": "Pehli Dafa", "subtitle": "Bollywood", "url": "https://www.youtube.com/results?search_query=pehli+dafa+song"},
        {"title": "Khwab", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=khwab+song"},
        {"title": "Don't Worry", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=dont+worry+song"},
        {"title": "True", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=true+song"},
        {"title": "Stay With Me", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=stay+with+me+song"},
        {"title": "In A Beautiful Way", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=in+a+beautiful+way+song"},
        {"title": "The Reasons Of My Smiles", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=the+reasons+of+my+smiles+song"},
        {"title": "No Fate", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=no+fate+song"},
        {"title": "Sudden Shower", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=sudden+shower+song"},
      ];
    } else if (category == "Movie Picks") {
      return [
        {"title": "Twinkling Watermelon", "subtitle": "K-Drama", "url": "https://www.youtube.com/results?search_query=twinkling+watermelon+trailer"},
        {"title": "Twenty-Five Twenty-One (2521)", "subtitle": "K-Drama", "url": "https://www.youtube.com/results?search_query=twenty+five+twenty+one+trailer"},
        {"title": "Love O2O", "subtitle": "C-Drama", "url": "https://www.youtube.com/results?search_query=love+o2o+trailer"},
        {"title": "XO, Kitty", "subtitle": "Rom-Com Series", "url": "https://www.youtube.com/results?search_query=xo+kitty+trailer"},
        {"title": "To All The Boys I've Loved Before", "subtitle": "Rom-Com", "url": "https://www.youtube.com/results?search_query=to+all+the+boys+ive+loved+before+trailer"},
        {"title": "My Oxford Year", "subtitle": "Romance", "url": "https://www.youtube.com/results?search_query=my+oxford+year+trailer"},
        {"title": "K-Pop: Demon Hunters", "subtitle": "Animation", "url": "https://www.youtube.com/results?search_query=kpop+demon+hunters+trailer"},
        {"title": "When I Fly Towards You", "subtitle": "C-Drama", "url": "https://www.youtube.com/results?search_query=when+i+fly+towards+you+trailer"},
        {"title": "Pswaram Mayam", "subtitle": "Favorite", "url": "https://www.youtube.com/results?search_query=pswaram+mayam+movie"},
        {"title": "Bangalore Days", "subtitle": "Malayalam", "url": "https://www.youtube.com/results?search_query=bangalore+days+trailer"},
        {"title": "Jacobinte Swargarajyam", "subtitle": "Malayalam", "url": "https://www.youtube.com/results?search_query=jacobinte+swargarajyam+trailer"},
        {"title": "Vinodayathra", "subtitle": "Malayalam", "url": "https://www.youtube.com/results?search_query=vinodayathra+movie"},
        {"title": "Classmates", "subtitle": "Malayalam", "url": "https://www.youtube.com/results?search_query=classmates+malayalam+trailer"},
      ];
    } else if (category == "New Skills to Learn") {
      return [
        {"title": "Painting", "subtitle": "Express your emotions", "url": "https://www.youtube.com/results?search_query=easy+acrylic+painting+for+beginners"},
        {"title": "Crochet", "subtitle": "Create cozy crafts", "url": "https://www.youtube.com/results?search_query=how+to+crochet+for+beginners"},
        {"title": "Origami", "subtitle": "Art of paper folding", "url": "https://www.youtube.com/results?search_query=easy+origami+for+beginners"},
        {"title": "Calligraphy", "subtitle": "Beautiful handwriting", "url": "https://www.youtube.com/results?search_query=calligraphy+for+beginners"},
        {"title": "Scrapbooking", "subtitle": "Document your life", "url": "https://www.youtube.com/results?search_query=aesthetic+scrapbook+journaling+for+beginners"},
      ];
    } else {
      return [
        {"title": "Deep Breathing", "subtitle": "5 mins - Calm your mind", "url": "https://www.youtube.com/results?search_query=5+minute+deep+breathing+instructions"},
        {"title": "Gentle Stretching", "subtitle": "10 mins - Release tension", "url": "https://www.youtube.com/results?search_query=10+minute+gentle+stretching+routine"},
        {"title": "Progressive Muscle Relaxation", "subtitle": "15 mins - Full body", "url": "https://www.youtube.com/results?search_query=progressive+muscle+relaxation+guided"},
        {"title": "Mindful Walking", "subtitle": "10 mins - Ground yourself", "url": "https://www.youtube.com/results?search_query=mindful+walking+meditation"},
        {"title": "Yoga for Beginners", "subtitle": "20 mins - Feel flexible", "url": "https://www.youtube.com/results?search_query=20+minute+yoga+for+beginners"},
      ];
    }
  }

  Color _getCategoryColor(String category) {
    if (category == "Uplifting Songs") return Colors.orange;
    if (category == "Movie Picks") return Colors.indigo;
    if (category == "New Skills to Learn") return Colors.deepOrange;
    return Colors.green;
  }

  IconData _getCategoryIcon(String category) {
    if (category == "Uplifting Songs") return Icons.music_note;
    if (category == "Movie Picks") return Icons.movie_outlined;
    if (category == "New Skills to Learn") return Icons.brush;
    return Icons.self_improvement;
  }
}
