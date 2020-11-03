//
//  Wallet.swift
//  VeracityArWeave
//
//  Created by Chu Anh Minh on 10/30/20.
//

import Foundation

public struct Wallet: Codable {
    struct PrivateKey: Codable {
        let kty: String
        let n: String
        let e: String
        let d: String
        let p: String
        let q: String
        let dp: String
        let dq: String
        let qi: String
    }

    let address: String
    let key: PrivateKey
}

public struct WalletTransaction: Codable, Hashable {
    let transactionId: String
    let address: String
}

extension Wallet {
    static func tmp() -> Wallet {
        return Wallet(address: "UZkVHVliAKw3vDqXTXLGKN_cHrcqsoQuZy7nAQpowsc",
                      key: PrivateKey(kty: "RSA",
                                      n: "qZN7AGpR7Y0bZy_ImV-QhyQXNI50V52eowZc6UKAFnzuemiyn--6HlDL4dFG8I_mvcoYbbS3PzDeVjq-Lystw6nkRtQ28f7a83DWtMQG8uCN5xjFz10YBDPstzID9XU2Nv3-kcHwzO5WZSKYu5dqXsm-nJ_sG9berwFY8MxZ5aIcq-FwHc2pRGMW0AZJIRHbffIj-XOzRd3H2n26C_TvE7lYGa8-bGbIqzSnvjEpmp_Y8IXzMHkW9yyPhImrrk2e-mijyq-Ji3wxvBaCT1pwI2QB4u1A-jmUjrGSzX6J2oLHeAcjKVEo1i4j_SMlOMho8pwmUpv94jSq5TsGFc6i4nMr0xgfjRqHujoFdPqHVaVz1jCYXKuoksJqHtIAZ_F9u46fQ9q6KA0s1GVUZfB-p_hFF7xxqFfvdylGBO3G33mTLS8rs5ShvqwfQuEoc4OTaUIG75I87F1N_xE042rS2vQgxL7u4AJepczU_B7Y_YpY5WssQRkyVrogjIT82wpAjmvDdnWT2W_p7jArhWYacYqj4uEASlQ12ZWKt2fWvbJiHWSsocPsU46D07hkQFrdhPsP2Y_Dd9Ll2KHamhZ5P3m7_6yghDomxYWfZ1XLutnfPT7SNB3r7CwZ2GW52PeVC_DPlp4hQi_fwpS5ha6EgsDQTvAdAjvmK3-NbaaVvwE",
                                      e: "AQAB", d: "gjR0gIgiaiUrwlpFS8a-AZYrnzY2jMPA9-o90vk1wo6gyiqz5Ow8W2Ssd7KqJrJHeLjBcxMMlR-fyFQIjc04sYE0f1IY8k0-ryeYJGpT74-ORcCWujb_5tI70xo7QfCC9UyneCGTFLd4bOVYosmLaka77iU5NNMSXwvIz_QInrKQE0XhQXEVpCX1cTsyUYsVnqobB0HYiC_XcaOSA_ZI0DtDM02Ev9VYBWVD21yCVnCgMWaYqUKA6L81X44Z3ZdKF3nbMhkAorJ0ubgKzIVjjzkN3cFQYBFwSPR-BP1BOh-qqzXHwMTJd1MsXQTsYqI3Ovm8zzdphJPuGF7uuDXWiIvaXm_ctCnoh8hpDZymG-zp7u8JpZWozqxkPC_2hw3ZBYJPXyKg_EYq6FGxpiLW3yZ_oRLb7nO3CHpRMCfWrl_aVUuxzpzUnH3kJRrefiOMhBomNh4Hqw4Ud9Q9vS5gsKh0b0ARI0mIN2cv2CGycMN4KjZzJMhRn1rzroitEqkLZJwpd9YysNPuCGMDvexE_bzsJqzW8qJ0bRGw_eGtx7nRJvlp3qTzCxx6-yfmDF-zGKgKRs90GP5ZbJvNPsoe18MEMSeCizsGcG6p-Zg3nQ04tT6LholoxTmoXaFzDLsWdtgbxQcxcz_agYt_QZbKZagA6l2OMMRCuQD5BDbLLcE",
                                      p: "1VmFZCCxYg_NufY9F4nhMYnwaBqunJsgyifG2eI8JGoXbeOthUWmtk-JVPF1N9tMn9DPamd-CKQeMIsXPvulpNGMQFY7HWBmM3c5V4QxPq0kb6LQWgsf8eOQBu-yXO96jr5cePRmztPVTNKQpVQyDwXRZH4ILgPkh_uTbBiy1iHaR7bDbti9T2wecnHAXL44wEld8QEnOzu1HzY6-_EZabkE7L_Wyp2MQD0O36dWl71d5oBpg9TfodhsggA0uIUaFbOTpkpfUJUUNgRaR3EkqPwMGS8cQE9FTOrHOklngThJKNkZU5OVn5tA5CYe9crJYVLuyajVWsQ1JY0MRTQ9iQ",
                                      q: "y3nISAgD7tFr_9qvsztF-DsiDEWNoB2ykqfAb8yI04Whnjzvh7ZZ5XoVIUwF0OJjlcscPHbazTAwup2P2g1lVdV1VZUUHBgV69iFBcekKiMCI4HTWIAOfsfVKjNbvIbrR5esWss4blbSehoPHxfsZwGM1kxTUx-2_TH5SzeaW5jwXfQLzAaBDS49IklUYekxJQVNpfkBIzUba-KqACi59olGfFOJVoJmQxldxH_dGeH34mZEQEavQV2LB2OK460gnU0iw3Rs4-dLgfffjxu3Sj_DkH9w1AvRMPMcfrsUImj7Ir-WDnwZo7-OoHhkYuG9JVF1tTzB3W01Mm_owBhPuQ",
                                      dp: "L4xqDCy1G9PF1-InL23NQIsrhygbLk_seOFwkfK30K3MVvNdIsypIQyM4N-HblFzvFJ_R4mVLzvUdqEpJyJSgm8pQNV3C08GuAWkQ_r0NrHD4xV4Nfkwv2omGUWmjMvalqGaXmKp3wKbESoEjrQ7C9oSFsF39Tls31mUO40tnkehLEZxO-0WE_NWvc7YPlMutrwjMak-IxdlgHVHpArRzRwtGs6Ogk2milKRVAspY1wS52JLIdR5mspvNHHzTgRsEdYZ2__LSlxPStKhhDaVIww5bgtv0m1YVpIkoLrnVIdE1tO7r0K_H_kr9yz_zWvKgeRHz63PDxGXfqz2xR2lcQ",
                                      dq: "Rah3bFFyJzwCoSCYrd9I4OY9jb3x8jK4g4RyWNPIs8E3xxhNWESRGgJlYXTJOO2H8iwKipiV51DsHbb7HEchvfTJqnbS35tPReJmB8iE5vf9L3Kui8mrLLP0wfG7Iht-SJAgLSUNOJj4jVyGeLqT79-T-3k9vWNKHfwRwDJU4a7F-yQlNb-0RnLh8u7vuGVAsc_S-VL5lLgFnzWFxXAr2b69JqrihX82yxnQBAlSBB5b4mHoU6jfLp17jxgA4FjQpYlWsVsWPB9etivJmRB_-ydBKCK42Z8CCqPvyWL6TZ1q_EZidKr_jBN0HHOayk9FlZUBmv4l0EwmvhGZuMmZ4Q",
                                      qi: "NF9lw1mCr3YJ7SXDifyXFcWlGA7FeSbBXZdt64JDQyFSwIE4MkrddY8eH3Zm5CAbLoXwDb5vPixjjCGiO3L2OBZxMzdjnBYVPTn2M7-1RxpBA1VsJDbcfJYw0WmBPetyF5RhucS_YNfx_fLIBFpaJXFoKY6o8VfhKHVL6elKA22dXPlcSBEPg087TA1rsOzzQ0moJaRWJcytJlg14fnLPPw28YwHtEme0-ABuUoNAD4ONxtwOjgEST4NkpikuupSMOFNARIvI4pcy17YdO2-DoFxxAyan031GounzcSeyTxAwgGTB4L6hFiKzHhcOTOOP660Dif5egXC_rF_Qwj16g"))
    }
}
