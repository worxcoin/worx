// Copyright (c) 2010 Satoshi Nakamoto
// Copyright (c) 2009-2014 The Bitcoin developers
// Copyright (c) 2014-2015 The Dash developers
// Copyright (c) 2015-2017 The PIVX developers
// Copyright (c) 2018 The Worx developers
// Distributed under the MIT software license, see the accompanying
// file COPYING or http://www.opensource.org/licenses/mit-license.php.

#include "chainparams.h"

#include "random.h"
#include "util.h"
#include "utilstrencodings.h"

#include <assert.h>

#include <boost/assign/list_of.hpp>


using namespace std;
using namespace boost::assign;

struct SeedSpec6 {
    uint8_t addr[16];
    uint16_t port;
};

#include "chainparamsseeds.h"

/**
 * Main network
 */

//! Convert the pnSeeds6 array into usable address objects.
static void convertSeed6(std::vector<CAddress>& vSeedsOut, const SeedSpec6* data, unsigned int count)
{
    // It'll only connect to one or two seed nodes because once it connects,
    // it'll get a pile of addresses with newer timestamps.
    // Seed nodes are given a random 'last seen time' of between one and two
    // weeks ago.
    const int64_t nOneWeek = 7 * 24 * 60 * 60;
    for (unsigned int i = 0; i < count; i++) {
        struct in6_addr ip;
        memcpy(&ip, data[i].addr, sizeof(ip));
        CAddress addr(CService(ip, data[i].port));
        addr.nTime = GetTime() - GetRand(nOneWeek) - nOneWeek;
        vSeedsOut.push_back(addr);
    }
}

//   What makes a good checkpoint block?
// + Is surrounded by blocks with reasonable timestamps
//   (no blocks before with a timestamp after, none after with
//    timestamp before)
// + Contains no strange transactions

static Checkpoints::MapCheckpoints mapCheckpoints =
    boost::assign::map_list_of
	(0, uint256("0x00000b05264210031b3cf6ad2ec6946e669b9d3b8fa7c7c9cbcc8e02742ed37c"))
	(100000, uint256("0x1fc463a77da8dbe06ed9c61e0b56d3fa0b454c5f97380a02df990efc320b9024"))
	(200000, uint256("0xf3736b1bc9fff59e0f2e409565a2a923a3ea1138ecc60c8afcc51968cedffcb0"))
	(300000, uint256("0x4da51c20fb01120cc36c8ff9f398fea394c66e89e7bdb95c03cd3027aeccd96d"))
	(400000, uint256("0x69f5de6d04c9bf15336c5ca79f90e013fc6cb29576bed296a25732f8b77b2170"))
	(450000, uint256("0x739a4a48bafac77012fcb4d300ae39aeb56f2bcb1e42ea59bdbc0ba89bae9c82"))
	(475000, uint256("0x87a20ef7fcf5983ba2da1bdce5c49a6cd2e099e10d0920a6381ecb92d9fdc5d0"))
	(500000, uint256("0xc667b2306d2ae6418573e7927d04c79c9ff6351a38b2dbd690e0d5ec9c6c1ef2"))
	(525000, uint256("0x56516fabe66900633d6778f2174fcea35258a6c5f3f1d5fb8832aee04d03a654"))
	(530000, uint256("0xdf10d5dec03cc81bcf65b6d66b18d8ae0aa1ecf74ea967b180df36c0b4340d52"))
	(535000, uint256("0x44f2acb6f5f164cf989b94046e521301517171832a49bc784550f93507b68017"))
	(540003, uint256("0x1177a1b25e1f369ea607b17f2a2e4ac85cd2f6f0af3927b8013ded877a3ea7b6"))
	(545000, uint256("0x0f05c9ce4f24dadda432fe28be4757cce3c9b618165923a5d393f7b30b85b029"))
	(550000, uint256("0x589f11fc1e2aeb2945a3159306066e8a76db2862f8c03e595a7e768caceb213c"))
	(551000, uint256("0x0e7c56e5e054603302e53b2ebcbdea9d854d9aac122298d492cfd2b002574bb4"))
	(552000, uint256("0xd1d40452154a61dc819e1fda522ecd45914608b0e7dbf09a8a66a3fdd0935232"));

static const Checkpoints::CCheckpointData data = {
    &mapCheckpoints,
    1524956400, // * UNIX timestamp of last checkpoint block
    0,    // * total number of transactions between genesis and last checkpoint
                //   (the tx=... number in the SetBestChain debug.log lines)
    2000        // * estimated number of transactions per day after checkpoint
};

static Checkpoints::MapCheckpoints mapCheckpointsTestnet =
    boost::assign::map_list_of(0, uint256("0x"));
static const Checkpoints::CCheckpointData dataTestnet = {
    &mapCheckpointsTestnet,
    0,
    0,
    0};

static Checkpoints::MapCheckpoints mapCheckpointsRegtest =
    boost::assign::map_list_of(0, uint256("0x"));
static const Checkpoints::CCheckpointData dataRegtest = {
    &mapCheckpointsRegtest,
    0,
    0,
    0};

class CMainParams : public CChainParams
{
public:
    CMainParams()
    {
        networkID = CBaseChainParams::MAIN;
        strNetworkID = "main";
        /**
         * The message start string is designed to be unlikely to occur in normal data.
         * The characters are rarely used upper ASCII, not valid as UTF-8, and produce
         * a large 4-byte int at any alignment.
         */
        pchMessageStart[0] = 0xf4;
        pchMessageStart[1] = 0x49;
        pchMessageStart[2] = 0xba;
        pchMessageStart[3] = 0x56;
        vAlertPubKey = ParseHex("048ec5c51b08b683c439315cae1ce6ee553eba63d0af3e3040bc9ef72f2fb532d44585dfcbc4c718618daef3ffd887b3d033895b6fc3628abf4031390d38b37957");
        nDefaultPort = 3300;
        bnProofOfWorkLimit = ~uint256(0) >> 20;
        nSubsidyHalvingInterval = 210000;
        nMaxReorganizationDepth = 100;
        nEnforceBlockUpgradeMajority = 750;
        nRejectBlockOutdatedMajority = 950;
        nToCheckBlockUpgradeMajority = 1000;
        nMinerThreads = 0;
        nTargetTimespan = 1 * 60;
        nTargetSpacing = 1 * 60;
        nLastPOWBlock = 1430;
        nMaturity = 100;
        nMasternodeCountDrift = 20;
	nMasternodeColleteralLimxDev = 5000; //Params().MasternodeColleteralLimxDev()
        nModifierUpdateBlock = 1; // we use the version 2 for dmd
        nMaxMoneyOut = 21000000 * COIN;
        strDeveloperFeePayee = "WaX6WwwB8C5s5WRxCQzNpo6CAEL5uhFoAG";

        const char* pszTimestamp = "29th April - Worx Birthday YAY!";
        CMutableTransaction txNew;
        txNew.vin.resize(1);
        txNew.vout.resize(1);
        txNew.vin[0].scriptSig = CScript() << 486604799 << CScriptNum(4) << vector<unsigned char>((const unsigned char*)pszTimestamp, (const unsigned char*)pszTimestamp + strlen(pszTimestamp));
        txNew.vout[0].nValue = 0 * COIN;
        txNew.vout[0].scriptPubKey = CScript() << ParseHex("04c2851936b2196beb85e7eca91697884918bc6deacd4ca49b52418d376a092913bde42bc868178c0ed436c184259edd0bf2a3ff32388facd6d6332e8de31c9121") << OP_CHECKSIG;
        genesis.vtx.push_back(txNew);
        genesis.hashPrevBlock = 0;
        genesis.hashMerkleRoot = genesis.BuildMerkleTree();
        genesis.nVersion = 1;
        genesis.nTime = 1524956400;
        genesis.nBits = 0x1e0ffff0;
        genesis.nNonce = 21939425;
		
        hashGenesisBlock = genesis.GetHash();

	//printf("%s\n", hashGenesisBlock.ToString().c_str());
	//printf("%s\n", genesis.hashMerkleRoot.ToString().c_str());

        assert(hashGenesisBlock == uint256("0x00000b05264210031b3cf6ad2ec6946e669b9d3b8fa7c7c9cbcc8e02742ed37c"));
        assert(genesis.hashMerkleRoot == uint256("0x8d07c3e3724c17793bf8794d8bdeb30e33cf8ea4195142706031275f95747972"));
        

        vSeeds.push_back(CDNSSeedData("seed01.worx.global", "seed01.worx.global"));
	vSeeds.push_back(CDNSSeedData("seed02.worx.global", "seed02.worx.global"));
	vSeeds.push_back(CDNSSeedData("seed03.worx.global", "seed03.worx.global"));
        //vFixedSeeds.clear();
        //vSeeds.clear();

        base58Prefixes[PUBKEY_ADDRESS] = std::vector<unsigned char>(1, 73);
        base58Prefixes[SCRIPT_ADDRESS] = std::vector<unsigned char>(1, 135);
        base58Prefixes[SECRET_KEY] = std::vector<unsigned char>(1, 193);
        base58Prefixes[EXT_PUBLIC_KEY] = boost::assign::list_of(0x04)(0x88)(0xB2)(0x1E).convert_to_container<std::vector<unsigned char> >();
        base58Prefixes[EXT_SECRET_KEY] = boost::assign::list_of(0x04)(0x88)(0xAD)(0xE4).convert_to_container<std::vector<unsigned char> >();
        // 	BIP44 coin type is from https://github.com/satoshilabs/slips/blob/master/slip-0044.md 109 	0x8000006d
        base58Prefixes[EXT_COIN_TYPE] = boost::assign::list_of(0x80)(0x00)(0x00)(0x6d).convert_to_container<std::vector<unsigned char> >();

        convertSeed6(vFixedSeeds, pnSeed6_main, ARRAYLEN(pnSeed6_main));

        fRequireRPCPassword = true;
        fMiningRequiresPeers = false;
        fAllowMinDifficultyBlocks = false;
        fDefaultConsistencyChecks = false;
        fRequireStandard = true;
        fMineBlocksOnDemand = false;
        fSkipProofOfWorkCheck = false;
        fTestnetToBeDeprecatedFieldRPC = false;
        fHeadersFirstSyncingActive = false;


        nPoolMaxTransactions = 3;
        strSporkKey = "04104c1594c136ea1fc859321750518ef486c73eeb8db787b006d13211ad9d88162a2bb840ba03d3ee801fd85c7e47fb14f25110cf79b563106bcb178dac555bd1";
        strDarksendPoolDummyAddress = "AcmpqXViWUXNroqVNYRdKjKrFM6PNa1oTM";
        nStartMasternodePayments = 1523116993; 
    }

    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        return data;
    }
};
static CMainParams mainParams;

/**
 * Testnet (v3)
 */
class CTestNetParams : public CMainParams
{
public:
    CTestNetParams()
    {
        networkID = CBaseChainParams::TESTNET;
        strNetworkID = "test";
        pchMessageStart[0] = 0xcf;
        pchMessageStart[1] = 0x64;
        pchMessageStart[2] = 0xac;
        pchMessageStart[3] = 0x15;
        vAlertPubKey = ParseHex("048ec5c51b08b683c439315cae1ce6ee553eba63d0af3e3040bc9ef72f2fb532d44585dfcbc4c718618daef3ffd887b3d033895b6fc3628abf4031390d38b37957");
        nDefaultPort = 3310;
        nEnforceBlockUpgradeMajority = 51;
        nRejectBlockOutdatedMajority = 75;
        nToCheckBlockUpgradeMajority = 100;
        nMinerThreads = 0;
        nTargetTimespan = 1 * 60;
        nTargetSpacing = 1 * 60;
        nLastPOWBlock = 200;
        nMaturity = 15;
        nModifierUpdateBlock = 51197; //approx Mon, 30 Apr 2018 04:00:00 GMT
        nMaxMoneyOut = 90000000 * COIN;
        strDeveloperFeePayee = "---";

        //! Modify the testnet genesis block so the timestamp is valid for a later start.
        genesis.nTime = 1524956401;
        genesis.nNonce = 20839010;


        hashGenesisBlock = genesis.GetHash();

        assert(hashGenesisBlock == uint256("0x00000d71c345b3b39c15eca6b14ffeec0f9fc9709d822739a20bf93c31e25ffd"));

        vFixedSeeds.clear();
        vSeeds.clear();

        base58Prefixes[PUBKEY_ADDRESS] = std::vector<unsigned char>(1, 83);
        base58Prefixes[SCRIPT_ADDRESS] = std::vector<unsigned char>(1, 18);
        base58Prefixes[SECRET_KEY] = std::vector<unsigned char>(1, 193);
        // Testnet Worx BIP32 pubkeys start with 'DRKV'
        base58Prefixes[EXT_PUBLIC_KEY] = boost::assign::list_of(0x3a)(0x80)(0x61)(0xa0).convert_to_container<std::vector<unsigned char> >();
        // Testnet Worx BIP32 prvkeys start with 'DRKP'
        base58Prefixes[EXT_SECRET_KEY] = boost::assign::list_of(0x3a)(0x80)(0x58)(0x37).convert_to_container<std::vector<unsigned char> >();
        // Testnet Worx BIP44 coin type is '1' (All coin's testnet default)
        base58Prefixes[EXT_COIN_TYPE] = boost::assign::list_of(0x80)(0x00)(0x00)(0x01).convert_to_container<std::vector<unsigned char> >();

        convertSeed6(vFixedSeeds, pnSeed6_test, ARRAYLEN(pnSeed6_test));


        fRequireRPCPassword = true;
        fMiningRequiresPeers = true;
        fAllowMinDifficultyBlocks = true;
        fDefaultConsistencyChecks = false;
        fRequireStandard = false;
        fMineBlocksOnDemand = false;
        fTestnetToBeDeprecatedFieldRPC = true;



        nPoolMaxTransactions = 2;
        strSporkKey = "04104c1594c136ea1fc859321750518ef486c73eeb8db787b006d13211ad9d88162a2bb840ba03d3ee801fd85c7e47fb14f25110cf79b563106bcb178dac555bd1";
        strDarksendPoolDummyAddress = "";
        nStartMasternodePayments = 1523116994;
    }
    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        return dataTestnet;
    }
};
static CTestNetParams testNetParams;

/**
 * Regression test
 */
class CRegTestParams : public CTestNetParams
{
public:
    CRegTestParams()
    {
        networkID = CBaseChainParams::REGTEST;
        strNetworkID = "regtest";
        strNetworkID = "regtest";
        pchMessageStart[0] = 0x65;
        pchMessageStart[1] = 0xa7;
        pchMessageStart[2] = 0x54;
        pchMessageStart[3] = 0xc1;
        nSubsidyHalvingInterval = 150;
        nEnforceBlockUpgradeMajority = 750;
        nRejectBlockOutdatedMajority = 950;
        nToCheckBlockUpgradeMajority = 1000;
        nMinerThreads = 1;
        nTargetTimespan = 24 * 60 * 60;
        nTargetSpacing = 1 * 60;
        bnProofOfWorkLimit = ~uint256(0) >> 1;
        genesis.nTime = 1524956405;
        genesis.nBits = 0x207fffff;
        genesis.nNonce = 20542301;
        strDeveloperFeePayee = "---";
		
        hashGenesisBlock = genesis.GetHash();
	
	nDefaultPort = 3320;

        assert(hashGenesisBlock == uint256("0x71122de3457829075570e52b32fb5c5a983f2200dcdb438c956e8f8dafb86aae"));

        vFixedSeeds.clear(); //! Testnet mode doesn't have any fixed seeds.
        vSeeds.clear();      //! Testnet mode doesn't have any DNS seeds.

        fRequireRPCPassword = false;
        fMiningRequiresPeers = false;
        fAllowMinDifficultyBlocks = true;
        fDefaultConsistencyChecks = true;
        fRequireStandard = false;
        fMineBlocksOnDemand = true;
        fTestnetToBeDeprecatedFieldRPC = false;
    }
    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        return dataRegtest;
    }
};
static CRegTestParams regTestParams;

/**
 * Unit test
 */
class CUnitTestParams : public CMainParams, public CModifiableParams
{
public:
    CUnitTestParams()
    {
        networkID = CBaseChainParams::UNITTEST;
        strNetworkID = "unittest";
        nDefaultPort = 3310;
        strDeveloperFeePayee = "---";
        vFixedSeeds.clear(); //! Unit test mode doesn't have any fixed seeds.
        vSeeds.clear();      //! Unit test mode doesn't have any DNS seeds.

        fRequireRPCPassword = false;
        fMiningRequiresPeers = false;
        fDefaultConsistencyChecks = true;
        fAllowMinDifficultyBlocks = false;
        fMineBlocksOnDemand = true;
    }

    const Checkpoints::CCheckpointData& Checkpoints() const
    {
        // UnitTest share the same checkpoints as MAIN
        return data;
    }

    //! Published setters to allow changing values in unit test cases
    virtual void setSubsidyHalvingInterval(int anSubsidyHalvingInterval) { nSubsidyHalvingInterval = anSubsidyHalvingInterval; }
    virtual void setEnforceBlockUpgradeMajority(int anEnforceBlockUpgradeMajority) { nEnforceBlockUpgradeMajority = anEnforceBlockUpgradeMajority; }
    virtual void setRejectBlockOutdatedMajority(int anRejectBlockOutdatedMajority) { nRejectBlockOutdatedMajority = anRejectBlockOutdatedMajority; }
    virtual void setToCheckBlockUpgradeMajority(int anToCheckBlockUpgradeMajority) { nToCheckBlockUpgradeMajority = anToCheckBlockUpgradeMajority; }
    virtual void setDefaultConsistencyChecks(bool afDefaultConsistencyChecks) { fDefaultConsistencyChecks = afDefaultConsistencyChecks; }
    virtual void setAllowMinDifficultyBlocks(bool afAllowMinDifficultyBlocks) { fAllowMinDifficultyBlocks = afAllowMinDifficultyBlocks; }
    virtual void setSkipProofOfWorkCheck(bool afSkipProofOfWorkCheck) { fSkipProofOfWorkCheck = afSkipProofOfWorkCheck; }
};
static CUnitTestParams unitTestParams;


static CChainParams* pCurrentParams = 0;

CModifiableParams* ModifiableParams()
{
    assert(pCurrentParams);
    assert(pCurrentParams == &unitTestParams);
    return (CModifiableParams*)&unitTestParams;
}

const CChainParams& Params()
{
    assert(pCurrentParams);
    return *pCurrentParams;
}

CChainParams& Params(CBaseChainParams::Network network)
{
    switch (network) {
    case CBaseChainParams::MAIN:
        return mainParams;
    case CBaseChainParams::TESTNET:
        return testNetParams;
    case CBaseChainParams::REGTEST:
        return regTestParams;
    case CBaseChainParams::UNITTEST:
        return unitTestParams;
    default:
        assert(false && "Unimplemented network");
        return mainParams;
    }
}

void SelectParams(CBaseChainParams::Network network)
{
    SelectBaseParams(network);
    pCurrentParams = &Params(network);
}

bool SelectParamsFromCommandLine()
{
    CBaseChainParams::Network network = NetworkIdFromCommandLine();
    if (network == CBaseChainParams::MAX_NETWORK_TYPES)
        return false;

    SelectParams(network);
    return true;
}

