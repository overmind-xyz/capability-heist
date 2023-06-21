module overmind::capability_heist_test {
    #[test_only]
    use std::string::String;
    #[test_only]
    use aptos_std::aptos_hash;
    #[test_only]
    use std::string;
    #[test_only]
    use aptos_framework::account;
    #[test_only]
    use aptos_std::capability;
    #[test_only]
    use std::features;
    #[test_only]
    use std::vector;
    #[test_only]
    use overmind::capability_heist;

    const ENTER_BANK_ANSWER: vector<u8> = x"811d26ef9f4bfd03b9f25f0a8a9fa7a5662460773407778f2d10918037194536091342f3724a9db059287c0d06c6942b66806163964efc0934d7246d1e4a570d";
    const TAKE_HOSTAGE_ANSWER: vector<u8> = x"eba903d4287aaaed303f48e14fa1e81f3307814be54503d4d51e1c208d55a1a93572f2514d1493b4e9823e059230ba7369e66deb826a751321bbf23b78772c4a";
    const GET_KEYCARD_ANSWER: vector<u8> = x"564e1971233e098c26d412f2d4e652742355e616fed8ba88fc9750f869aac1c29cb944175c374a7b6769989aa7a4216198ee12f53bf7827850dfe28540587a97";
    const OPEN_VAULT_ANSWER: vector<u8> = x"51d13ec71721d968037b05371474cbba6e0acb3d336909662489d0ff1bf58b028b67b3c43e04ff2aa112529e2b6d78133a4bb2042f9c685dc9802323ebd60e10";

    const ENTER_BANK_USER_ANSWER: vector<u8> = b"create";
    const TAKE_HOSTAGE_USER_ANSWER: vector<u8> = b"Yes";
    const GET_KEYCARD_USER_ANSWER: vector<u8> = b"2";
    const OPEN_VAULT_USER_ANSWER: vector<u8> = b"No";
    const FLAG: vector<u8> = x"f9799208009b78b356a4323fac28f48675420e976bcfb8375857b51d4f7f4a8def8c09f2aa09deb814a0aeef122232124e086815782932e99608080e96acbdaa";

    #[test_only]
    struct TestCapability has drop {}

    #[test_only]
    fun answer_test_question(answer: String): bool {
        let expected = x"301bb421c971fbb7ed01dcc3a9976ce53df034022ba982b97d0f27d48c4f03883aabf7c6bc778aa7c383062f6823045a6d41b8a720afbb8a9607690f89fbe1a7";

        expected == aptos_hash::sha3_512(*string::bytes(&answer))
    }

    #[test]
    fun test_init() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        assert!(capability_heist::check_robber_exists(@robber), 0);

        let resource_account_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_account_address);
        capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank());
        capability::acquire(&resource_account_signer, &capability_heist::new_open_vault());
        capability::acquire(&resource_account_signer, &capability_heist::new_get_keycard());
        capability::acquire(&resource_account_signer, &capability_heist::new_open_vault());
    }

    #[test]
    #[expected_failure(abort_code = 0, location = overmind::capability_heist)]
    fun test_init_access_denied() {
        let invalid_robber = account::create_account_for_test(@0xCAFE);
        capability_heist::init(&invalid_robber);
    }

    #[test]
    #[expected_failure(abort_code = 524303, location = aptos_framework::account)]
    fun test_init_already_initialized() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);
        capability_heist::init(&robber);
    }

    #[test]
    fun test_enter_bank() {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        features::change_feature_flags(
            &aptos_framework,
            vector[features::get_sha_512_and_ripemd_160_feature()],
            vector[]
        );

        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);
        capability_heist::enter_bank(&robber);

        capability::acquire(&robber, &capability_heist::new_enter_bank());
    }

    #[test]
    #[expected_failure(abort_code = 1, location = overmind::capability_heist)]
    fun test_enter_bank_robber_not_initialized() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::enter_bank(&robber);
    }

    #[test]
    fun test_take_hostage() {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        features::change_feature_flags(
            &aptos_framework,
            vector[features::get_sha_512_and_ripemd_160_feature()],
            vector[]
        );

        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        let resource_acccount_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_acccount_address);
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank()),
            &capability_heist::new_enter_bank(),
            &robber
        );

        capability_heist::take_hostage(&robber);
        capability::acquire(&robber, &capability_heist::new_take_hostage());
    }

    #[test]
    #[expected_failure(abort_code = 1, location = overmind::capability_heist)]
    fun test_take_hostage_robber_not_initialized() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::take_hostage(&robber);
    }

    #[test]
    #[expected_failure(abort_code = 393218, location = aptos_std::capability)]
    fun test_take_hostage_no_enter_bank_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);
        capability_heist::take_hostage(&robber);
    }

    #[test]
    fun test_get_keycard() {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        features::change_feature_flags(
            &aptos_framework,
            vector[features::get_sha_512_and_ripemd_160_feature()],
            vector[]
        );

        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        let resource_acccount_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_acccount_address);
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank()),
            &capability_heist::new_enter_bank(),
            &robber
        );
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_take_hostage()),
            &capability_heist::new_take_hostage(),
            &robber
        );

        capability_heist::get_keycard(&robber);
        capability::acquire(&robber, &capability_heist::new_get_keycard());
    }

    #[test]
    #[expected_failure(abort_code = 1, location = overmind::capability_heist)]
    fun test_get_keycard_robber_not_initialized() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::get_keycard(&robber);
    }

    #[test]
    #[expected_failure(abort_code = 393218, location = aptos_std::capability)]
    fun test_get_keycard_no_enter_bank_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);
        capability_heist::get_keycard(&robber);
    }

    #[test]
    #[expected_failure(abort_code = 393218, location = aptos_std::capability)]
    fun test_get_keycard_no_take_hostage_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        let resource_acccount_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_acccount_address);
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank()),
            &capability_heist::new_enter_bank(),
            &robber
        );

        capability_heist::get_keycard(&robber);
    }

    #[test]
    fun test_open_vault() {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        features::change_feature_flags(
            &aptos_framework,
            vector[features::get_sha_512_and_ripemd_160_feature()],
            vector[]
        );

        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        let resource_acccount_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_acccount_address);
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank()),
            &capability_heist::new_enter_bank(),
            &robber
        );
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_take_hostage()),
            &capability_heist::new_take_hostage(),
            &robber
        );
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_get_keycard()),
            &capability_heist::new_get_keycard(),
            &robber
        );

        capability_heist::open_vault(&robber);
        capability::acquire(&robber, &capability_heist::new_open_vault());
    }

    #[test]
    #[expected_failure(abort_code = 1, location = overmind::capability_heist)]
    fun test_open_vault_robber_not_initialized() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::open_vault(&robber);
    }

    #[test]
    #[expected_failure(abort_code = 393218, location = aptos_std::capability)]
    fun test_open_vault_no_enter_bank_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);
        capability_heist::open_vault(&robber);
    }

    #[test]
    #[expected_failure(abort_code = 393218, location = aptos_std::capability)]
    fun test_open_vault_no_take_hostage_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        let resource_acccount_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_acccount_address);
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank()),
            &capability_heist::new_enter_bank(),
            &robber
        );

        capability_heist::open_vault(&robber);
    }

    #[test]
    #[expected_failure(abort_code = 393218, location = aptos_std::capability)]
    fun test_open_vault_no_get_keycard_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        let resource_acccount_address =
            account::create_resource_address(&@robber, b"CapabilityHeist");
        let resource_account_signer = account::create_signer_for_test(resource_acccount_address);
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_enter_bank()),
            &capability_heist::new_enter_bank(),
            &robber
        );
        capability::delegate(
            capability::acquire(&resource_account_signer, &capability_heist::new_get_keycard()),
            &capability_heist::new_get_keycard(),
            &robber
        );

        capability_heist::open_vault(&robber);
    }

    #[test]
    fun test_all_answers_are_correct() {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        features::change_feature_flags(
            &aptos_framework,
            vector[features::get_sha_512_and_ripemd_160_feature()],
            vector[]
        );

        let user_flag = vector::empty();
        vector::append(&mut user_flag, aptos_hash::sha3_512(ENTER_BANK_USER_ANSWER));
        vector::append(&mut user_flag, aptos_hash::sha3_512(TAKE_HOSTAGE_USER_ANSWER));
        vector::append(&mut user_flag, aptos_hash::sha3_512(GET_KEYCARD_USER_ANSWER));
        vector::append(&mut user_flag, aptos_hash::sha3_512(OPEN_VAULT_USER_ANSWER));

        assert!(aptos_hash::sha3_512(user_flag) == FLAG, 0);
    }

    #[test]
    fun test_delegate_capability() {
        let robber = account::create_account_for_test(@robber);
        capability_heist::init(&robber);

        {
            let resource_account_address =
                account::create_resource_address(&@robber, b"CapabilityHeist");
            let resource_account_signer = account::create_signer_for_test(resource_account_address);
            capability::create(&resource_account_signer, &TestCapability {});
        };

        capability_heist::delegate_capability(&robber, &TestCapability {});
        capability::acquire(&robber, &TestCapability {});
    }

    #[test]
    fun test_answer_test_question() {
        let aptos_framework = account::create_account_for_test(@aptos_framework);
        features::change_feature_flags(&aptos_framework, vector[features::get_sha_512_and_ripemd_160_feature()], vector[]);

        assert!(answer_test_question(string::utf8(b"Test")), 0);
    }
}