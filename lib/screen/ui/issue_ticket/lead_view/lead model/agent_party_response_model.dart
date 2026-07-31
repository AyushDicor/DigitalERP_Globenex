import 'dart:convert';

AgentPartyResponseModel agentPartyResponseModelFromJson(String str) =>
    AgentPartyResponseModel.fromJson(json.decode(str));

class AgentPartyResponseModel {
  final bool? success;
  final List<AgentPartyData>? data;
  final String? message;
  final int? statusCode;

  AgentPartyResponseModel({
    this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory AgentPartyResponseModel.fromJson(Map<String, dynamic> json) =>
      AgentPartyResponseModel(
        success: json['success'],
        data: json['data'] != null
            ? List<AgentPartyData>.from(
            json['data'].map((x) => AgentPartyData.fromJson(x)))
            : [],
        message: json['message'],
        statusCode: json['status'],
      );
}

class AgentPartyData {
  final int? partyId;
  final String? partyName;

  AgentPartyData({this.partyId, this.partyName});

  factory AgentPartyData.fromJson(Map<String, dynamic> json) => AgentPartyData(
    partyId: json['partyid'],
    partyName: json['partyname'],
  );
}