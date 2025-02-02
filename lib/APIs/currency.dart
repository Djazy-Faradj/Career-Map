import 'dart:convert';
import 'package:career_map/firebase/firestore_methods.dart';
import 'package:http/http.dart' as http;

class CurrencyApi {
  // Credentials for the job salary data API
  final String _API_KEY = 'cur_live_zKKLDqkN5oWqIdl27lE3Cb2q4CDMIcrIT8ErX0Gr';

  Future<dynamic> loadData() async { // Parameters require a country and a job title to look for
    FirestoreMethods firestoreMethods = FirestoreMethods();
    String url = 
    'https://api.currencyapi.com/v3/latest?apikey=${_API_KEY}&currencies=AED%2CAFN%2CALL%2CAMD%2CANG%2CAOA%2CARS%2CAUD%2CAWG%2CAZN%2CBAM%2CBBD%2CBDT%2CBGN%2CBHD%2CBIF%2CBMD%2CBND%2CBOB%2CBRL%2CBSD%2CBTN%2CBWP%2CBYN%2CBYR%2CBZD%2CCAD%2CCDF%2CCHF%2CCLF%2CCLP%2CCNY%2CCOP%2CCRC%2CCUC%2CCUP%2CCVE%2CCZK%2CDJF%2CDKK%2CDOP%2CDZD%2CEGP%2CERN%2CETB%2CEUR%2CFJD%2CFKP%2CGBP%2CGEL%2CGGP%2CGHS%2CGIP%2CGMD%2CGNF%2CGTQ%2CGYD%2CHKD%2CHNL%2CHRK%2CHTG%2CHUF%2CIDR%2CILS%2CIMP%2CINR%2CIQD%2CIRR%2CISK%2CJEP%2CJMD%2CJOD%2CJPY%2CKES%2CKGS%2CKHR%2CKMF%2CKPW%2CKRW%2CKWD%2CKYD%2CKZT%2CLAK%2CLBP%2CLKR%2CLRD%2CLSL%2CLTL%2CLVL%2CLYD%2CMAD%2CMDL%2CMGA%2CMKD%2CMMK%2CMNT%2CMOP%2CMRO%2CMUR%2CMVR%2CMWK%2CMXN%2CMYR%2CMZN%2CNAD%2CNGN%2CNIO%2CNOK%2CNPR%2CNZD%2COMR%2CPAB%2CPEN%2CPGK%2CPHP%2CPKR%2CPLN%2CPYG%2CQAR%2CRON%2CRSD%2CRUB%2CRWF%2CSAR%2CSBD%2CSCR%2CSDG%2CSEK%2CSGD%2CSHP%2CSLL%2CSOS%2CSRD%2CSTD%2CSVC%2CSYP%2CSZL%2CTHB%2CTJS%2CTMT%2CTND%2CTOP%2CTRY%2CTTD%2CTWD%2CTZS%2CUAH%2CUGX%2CUSD%2CUYU%2CUZS%2CVEF%2CVND%2CVUV%2CWST%2CXAF%2CXAG%2CXAU%2CXCD%2CXDR%2CXOF%2CXPF%2CYER%2CZAR%2CZMK%2CZMW%2CZWL%2CXPT%2CXPD%2CBTC%2CETH%2CBNB%2CXRP%2CSOL%2CDOT%2CAVAX%2CMATIC%2CLTC%2CADA';

    try {
      final response = await http.get(
        Uri.parse(url),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['data'].isEmpty) { // Returns false if no information is found
          return false;
        } else { // Write the data to Firestore
          return data['data']; // Return the data
        }
      } else {
        throw Exception('Failed to load data (Status code: ${response.statusCode})');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}