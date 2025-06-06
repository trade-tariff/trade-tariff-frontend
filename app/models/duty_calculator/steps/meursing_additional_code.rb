module DutyCalculator
  module Steps
    class MeursingAdditionalCode < Steps::Base
      # TODO: This list technically hasn't changed since the mid 1980s but we should depend on the backend as a source of truth for this list
      POSSIBLE_MEURSING_ADDITIONAL_CODES = %w[
        000
        001
        002
        003
        004
        005
        006
        007
        008
        009
        010
        011
        012
        013
        015
        016
        017
        020
        021
        022
        023
        024
        025
        026
        027
        028
        029
        030
        031
        032
        033
        035
        036
        037
        040
        041
        042
        043
        044
        045
        046
        047
        048
        049
        050
        051
        052
        053
        055
        056
        057
        060
        061
        062
        063
        064
        065
        066
        067
        068
        069
        070
        071
        072
        073
        075
        076
        077
        080
        081
        082
        083
        084
        085
        086
        087
        088
        090
        091
        092
        095
        096
        100
        101
        102
        103
        104
        105
        106
        107
        108
        109
        110
        111
        112
        113
        115
        116
        117
        120
        121
        122
        123
        124
        125
        126
        127
        128
        129
        130
        131
        132
        133
        135
        136
        137
        140
        141
        142
        143
        144
        145
        146
        147
        148
        149
        150
        151
        152
        153
        155
        156
        157
        160
        161
        162
        163
        164
        165
        166
        167
        168
        169
        170
        171
        172
        173
        175
        176
        177
        180
        181
        182
        183
        185
        186
        187
        188
        190
        191
        192
        195
        196
        200
        201
        202
        203
        204
        205
        206
        207
        208
        209
        210
        211
        212
        213
        215
        216
        217
        220
        221
        260
        261
        262
        263
        264
        265
        266
        267
        268
        269
        270
        271
        272
        273
        275
        276
        300
        301
        302
        303
        304
        305
        306
        307
        308
        309
        310
        311
        312
        313
        315
        316
        317
        320
        321
        360
        361
        362
        363
        364
        365
        366
        367
        368
        369
        370
        371
        372
        373
        375
        376
        378
        400
        401
        402
        403
        404
        405
        406
        407
        408
        409
        410
        411
        412
        413
        415
        416
        417
        420
        421
        460
        461
        462
        463
        464
        465
        466
        467
        468
        470
        471
        472
        475
        476
        500
        501
        502
        503
        504
        505
        506
        507
        508
        509
        510
        511
        512
        513
        515
        516
        517
        520
        521
        560
        561
        562
        563
        564
        565
        566
        567
        568
        570
        571
        572
        575
        576
        600
        601
        602
        603
        604
        605
        606
        607
        608
        609
        610
        611
        612
        613
        615
        616
        620
        700
        701
        702
        703
        705
        706
        707
        708
        710
        711
        712
        715
        716
        720
        721
        722
        723
        725
        726
        727
        728
        730
        731
        732
        735
        736
        740
        741
        742
        745
        746
        747
        750
        751
        758
        759
        760
        761
        762
        765
        766
        768
        769
        770
        771
        778
        779
        780
        781
        785
        786
        788
        789
        798
        799
        800
        801
        802
        805
        806
        807
        808
        809
        810
        811
        818
        819
        820
        821
        822
        825
        826
        827
        828
        829
        830
        831
        838
        840
        841
        842
        843
        844
        845
        846
        847
        848
        849
        850
        851
        852
        853
        855
        856
        857
        858
        859
        860
        861
        862
        863
        864
        865
        866
        867
        868
        869
        870
        871
        872
        873
        875
        876
        877
        878
        879
        900
        901
        902
        903
        904
        905
        906
        907
        908
        909
        910
        911
        912
        913
        915
        916
        917
        918
        919
        940
        941
        942
        943
        944
        945
        946
        947
        948
        949
        950
        951
        952
        953
        955
        956
        957
        958
        959
        960
        961
        962
        963
        964
        965
        966
        967
        968
        969
        970
        971
        972
        973
        975
        976
        977
        978
        979
        980
        981
        982
        983
        984
        985
        986
        987
        988
        990
        991
        992
        995
        996
      ].freeze

      attribute :meursing_additional_code, :string

      validates :meursing_additional_code, format: { with: /\A\d{3}\z/ }, inclusion: { in: POSSIBLE_MEURSING_ADDITIONAL_CODES }

      def meursing_additional_code
        super || user_session.meursing_additional_code
      end

      def save!
        user_session.meursing_additional_code = meursing_additional_code
      end

      def next_step_path
        customs_value_path
      end

      def previous_step_path
        return annual_turnover_path if user_session.annual_turnover == 'yes'
        return planned_processing_path if user_session.planned_processing.present? && user_session.acceptable_processing?

        interstitial_path
      end
    end
  end
end
