pragma solidity ^0.5.11;

contract ChainCustody {

    enum StageName {COLLECT, EXAM, ANALYZE, RESULTS}

    struct Doc {
        address agent;
        string description;
    }

    struct Evidence {
        bytes32 id;
        uint32 caseID;

        address creator;
        address owner;

        string description;
        bool valid;

        StageName stage;

        mapping (uint8=>Doc) docs;
    }

    event Commit(bytes32 evidenceID, address agent, StageName stage, string description);
    event EvidenceTransfer(address old, address owner);
    event InvalidEvidence(bytes32 evidenceID);

    event GetInformation(
        bytes32 evidenceID,
        uint32 caseID,
        address creator,
        address owner,
        string description,
        bool valid,
        StageName stage
    );

    event GetExam(address agent, string description);

    event GetAnalisy(address agent, string description);

    event GetResults(address agent, string description);

    mapping (bytes32=>Evidence) evidences;
    address entity;

    constructor() public {
        entity = msg.sender;
    }

    function new_evidence(bytes32 evidenceID, uint32 caseID, string memory description) public {
        evidences[evidenceID].id = evidenceID;
        evidences[evidenceID].caseID = caseID;

        evidences[evidenceID].creator = msg.sender;
        evidences[evidenceID].owner = entity;

        evidences[evidenceID].description = description;

        evidences[evidenceID].stage = StageName.COLLECT;
        emit Commit(evidenceID, msg.sender, StageName.COLLECT, description);
    }

    function transfer(bytes32 evidenceID, address owner) public {
        if (evidences[evidenceID].owner == msg.sender) {
            emit EvidenceTransfer(evidences[evidenceID].owner, owner);
            evidences[evidenceID].owner = owner;
        }
    }

    function exam(bytes32 evidenceID, bool valid, string memory description) public {
        if (evidences[evidenceID].owner == msg.sender && evidences[evidenceID].stage == StageName.COLLECT) {
            evidences[evidenceID].docs[0] = Doc({agent: msg.sender, description: description});
            evidences[evidenceID].stage = StageName.EXAM;
            evidences[evidenceID].valid = valid;
            evidences[evidenceID].owner = entity;
            emit Commit(evidenceID, msg.sender, StageName.EXAM, description);
        }
    }

    function analyze(bytes32 evidenceID, string memory description) public {
        if (evidences[evidenceID].owner == msg.sender && evidences[evidenceID].stage == StageName.EXAM && evidences[evidenceID].valid) {
            evidences[evidenceID].docs[1] = Doc({agent: msg.sender, description: description});
            evidences[evidenceID].stage = StageName.ANALYZE;
            evidences[evidenceID].owner = entity;
            emit Commit(evidenceID, msg.sender, StageName.ANALYZE, description);
        }
    }

    function results(bytes32 evidenceID, string memory description) public {
        if (evidences[evidenceID].owner == msg.sender && evidences[evidenceID].stage == StageName.ANALYZE) {
            evidences[evidenceID].docs[2] = Doc({agent: msg.sender, description: description});
            evidences[evidenceID].stage = StageName.RESULTS;
            evidences[evidenceID].owner = entity;
            emit Commit(evidenceID, msg.sender, StageName.RESULTS, description);
        }
    }

    function invalid(bytes32 evidenceID) public {
        if (evidences[evidenceID].owner == msg.sender && evidences[evidenceID].stage == StageName.RESULTS) {
            evidences[evidenceID].owner = entity;
            emit  InvalidEvidence(evidenceID);
        }
    }

    function getInformation(bytes32 evidenceID) public {
        emit GetInformation(evidences[evidenceID].id,
            evidences[evidenceID].caseID,
            evidences[evidenceID].creator,
            evidences[evidenceID].owner,
            evidences[evidenceID].description,
            evidences[evidenceID].valid,
            evidences[evidenceID].stage
        );

        StageName stage = evidences[evidenceID].stage;

        if (stage == StageName.RESULTS) {
            emit GetExam(evidences[evidenceID].docs[0].agent, evidences[evidenceID].docs[0].description);
            emit GetAnalisy(evidences[evidenceID].docs[1].agent, evidences[evidenceID].docs[1].description);
            emit GetResults(evidences[evidenceID].docs[2].agent, evidences[evidenceID].docs[2].description);
        } else if (stage == StageName.ANALYZE) {
            emit GetExam(evidences[evidenceID].docs[0].agent, evidences[evidenceID].docs[0].description);
            emit GetAnalisy(evidences[evidenceID].docs[1].agent, evidences[evidenceID].docs[1].description);
        } else if (stage == StageName.EXAM) {
            emit GetExam(evidences[evidenceID].docs[0].agent, evidences[evidenceID].docs[0].description);
        }
    }
}