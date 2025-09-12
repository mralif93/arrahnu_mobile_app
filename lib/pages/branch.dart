import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constant/variables.dart';
import 'branch_selection_page.dart';

class BranchPage extends StatefulWidget {
  const BranchPage({super.key});

  @override
  State<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends State<BranchPage> {
  // Data Variables
  List collections = [];

  // Style
  final textHeaderStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final titleStyle = const TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 16,
  );

  final subtitleStyle = const TextStyle(
    fontWeight: FontWeight.normal,
    color: Colors.white,
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMMB Pajak Gadai-i', style: textHeaderStyle),
      ),
      body: RefreshIndicator(
        onRefresh: refreshDetails,
        child: FutureBuilder<List<String>>(  // Specify the generic type here
          future: fetchBranchDetails(),  // Using the corrected function name
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return ListView.separated(
                itemCount: snapshot.data!.length,  // Use ! to assert non-null
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index]),  // Use ! to assert non-null
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BranchSelectionPage(),
                        ),
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 0);
                },
              );
            } else {
              return const Center(child: Text('No branches found'));
            }
          },
        ),
      ),
    );
  }

  Future refreshDetails() async {
    return fetchBranchDetails();
  }

  Future<List<String>> fetchBranchDetails() async {
    // Get data from API
    var response = await http.get(Uri.parse('${Variables.baseUrl}/api/v2/pages/?type=product.BranchPage&fields=*'));
    
    if (response.statusCode == 200) {
      // Parse JSON to Dart object
      final jsonData = json.decode(response.body);
      
      // Based on the provided sample data, we need to access the 'items' array
      List<dynamic> items = jsonData['items'];
      
      // Create a list to store branch titles
      List<String> branches = [];
      
      // Extract branch titles from the items
      for (var item in items) {
        String branchTitle = item['title'];
        if (!branches.contains(branchTitle)) {
          branches.add(branchTitle);
        }
      }
      
      // Sort alphabetically
      branches.sort();
      
      return branches;
    } else {
      // Throw exception
      throw Exception('Failed to load Branch Info: ${response.statusCode}');
    }
  }
}
