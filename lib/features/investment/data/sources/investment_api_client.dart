import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/investment_scheme.dart';
import '../models/investor_transaction.dart';
import '../models/buy_units_request.dart';
import '../models/portfolio_holding.dart';

part 'investment_api_client.g.dart';

@RestApi()
abstract class InvestmentApiClient {
  factory InvestmentApiClient(Dio dio, {String? baseUrl}) = _InvestmentApiClient;

  @GET("/getAllSchemes")
  Future<List<InvestmentScheme>> getAllSchemes();

  @GET("/getAllInvestorTransactionsByInvestorId/{investorId}")
  Future<List<InvestorTransaction>> getInvestorTransactions({
    @Path('investorId') required String investorId,
  });

  @POST("/buyUnits")
  Future<InvestorTransaction> buyUnits({
    @Body() required BuyUnitsRequest request,
  });

  @GET("/getPortfolioByInvestorId/{investorId}")
  Future<List<PortfolioHolding>> getPortfolio({
    @Path('investorId') required String investorId,
  });

  @POST("/sellUnits")
  Future<InvestorTransaction> sellUnits({
    @Body() required Map<String, dynamic> request,
  });
}


