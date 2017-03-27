CREATE TABLE IF NOT EXISTS matches (
       id                               INTEGER PRIMARY KEY,
       competition_id                   INTEGER REFERENCES competitions(id),
       season_id                        INTEGER REFERENCES seasons(id),
       country                          TEXT,
       weather                          TEXT,
       match_type                       TEXT,
       result_type                      TEXT,
       attendance                       INTEGER,
       matchday                         INTEGER,
       winner                           INTEGER REFERENCES teams(id),
       kickoff                          TIMESTAMP WITH TIME ZONE,
       -- Other stuff, like officials, weather, attendance, result
       first_half_extra_start           TEXT,
       first_half_extra_stop            TEXT,
       first_half_extra_time            INTEGER,
       first_half_start                 TEXT,
       first_half_stop                  TEXT,
       first_half_time                  INTEGER,
       match_time                       INTEGER,
       second_half_extra_start          TEXT,
       second_half_extra_stop           TEXT,
       second_half_extra_time           INTEGER,
       second_half_start                TEXT,
       second_half_stop                 TEXT,
       second_half_time                 INTEGER
);

CREATE TABLE IF NOT EXISTS player_results (
       id                               SERIAL PRIMARY KEY,
       player_id                        INTEGER REFERENCES players(id),
       match_id                         INTEGER REFERENCES matches(id),
       team_id                          INTEGER REFERENCES teams(id),
       shirt_number                     INTEGER,
       position                         TEXT,
       sub_position                     TEXT,
       status                           TEXT,
       side                             TEXT,
       score                            INTEGER,
       competition_id                   INTEGER REFERENCES competitions(id),
       season_id                        INTEGER REFERENCES seasons(id),
       country                          TEXT,
       accurate_back_zone_pass          INTEGER,
       accurate_chipped_pass            INTEGER,
       accurate_corners_intobox         INTEGER,
       accurate_cross                   INTEGER,
       accurate_cross_nocorner          INTEGER,
       accurate_flick_on                INTEGER,
       accurate_freekick_cross          INTEGER,
       accurate_fwd_zone_pass           INTEGER,
       accurate_goal_kicks              INTEGER,
       accurate_keeper_sweeper          INTEGER,
       accurate_keeper_throws           INTEGER,
       accurate_launches                INTEGER,
       accurate_layoffs                 INTEGER,
       accurate_long_balls              INTEGER,
       accurate_pass                    INTEGER,
       accurate_pull_back               INTEGER,
       accurate_through_ball            INTEGER,
       accurate_throws                  INTEGER,
       aerial_lost                      INTEGER,
       aerial_won                       INTEGER,
       assist_attempt_saved             INTEGER,
       assist_blocked_shot              INTEGER,
       assist_free_kick_won             INTEGER,
       assist_handball_won              INTEGER,
       assist_own_goal                  INTEGER,
       assist_pass_lost                 INTEGER,
       assist_penalty_won               INTEGER,
       assist_post                      INTEGER,
       att_assist_openplay              INTEGER,
       att_assist_setplay               INTEGER,
       att_bx_centre                    INTEGER,
       att_bx_left                      INTEGER,
       att_bx_right                     INTEGER,
       att_cmiss_high                   INTEGER,
       att_cmiss_high_left              INTEGER,
       att_cmiss_high_right             INTEGER,
       att_cmiss_left                   INTEGER,
       att_cmiss_right                  INTEGER,
       att_fastbreak                    INTEGER,
       att_freekick_goal                INTEGER,
       att_freekick_miss                INTEGER,
       att_freekick_post                INTEGER,
       att_freekick_target              INTEGER,
       att_freekick_total               INTEGER,
       att_goal_high_centre             INTEGER,
       att_goal_high_left               INTEGER,
       att_goal_high_right              INTEGER,
       att_goal_low_centre              INTEGER,
       att_goal_low_left                INTEGER,
       att_goal_low_right               INTEGER,
       att_hd_goal                      INTEGER,
       att_hd_miss                      INTEGER,
       att_hd_post                      INTEGER,
       att_hd_target                    INTEGER,
       att_hd_total                     INTEGER,
       att_ibox_blocked                 INTEGER,
       att_ibox_goal                    INTEGER,
       att_ibox_miss                    INTEGER,
       att_ibox_post                    INTEGER,
       att_ibox_target                  INTEGER,
       att_lf_goal                      INTEGER,
       att_lf_target                    INTEGER,
       att_lf_total                     INTEGER,
       att_lg_centre                    INTEGER,
       att_lg_left                      INTEGER,
       att_lg_right                     INTEGER,
       att_miss_high                    INTEGER,
       att_miss_high_left               INTEGER,
       att_miss_high_right              INTEGER,
       att_miss_left                    INTEGER,
       att_miss_right                   INTEGER,
       att_obox_blocked                 INTEGER,
       att_obox_goal                    INTEGER,
       att_obox_miss                    INTEGER,
       att_obox_post                    INTEGER,
       att_obox_target                  INTEGER,
       att_obp_goal                     INTEGER,
       att_obx_centre                   INTEGER,
       att_obx_left                     INTEGER,
       att_obx_right                    INTEGER,
       att_obxd_left                    INTEGER,
       att_obxd_right                   INTEGER,
       att_one_on_one                   INTEGER,
       att_openplay                     INTEGER,
       att_pen_goal                     INTEGER,
       att_pen_miss                     INTEGER,
       att_pen_post                     INTEGER,
       att_pen_target                   INTEGER,
       att_post_high                    INTEGER,
       att_post_left                    INTEGER,
       att_post_right                   INTEGER,
       att_rf_goal                      INTEGER,
       att_rf_target                    INTEGER,
       att_rf_total                     INTEGER,
       att_setpiece                     INTEGER,
       att_sv_high_centre               INTEGER,
       att_sv_high_left                 INTEGER,
       att_sv_high_right                INTEGER,
       att_sv_low_centre                INTEGER,
       att_sv_low_left                  INTEGER,
       att_sv_low_right                 INTEGER,
       attempted_tackle_foul            INTEGER,
       attempts_conceded_ibox           INTEGER,
       attempts_conceded_obox           INTEGER,
       back_pass                        INTEGER,
       backward_pass                    INTEGER,
       ball_recovery                    INTEGER,
       big_chance_created               INTEGER,
       big_chance_missed                INTEGER,
       big_chance_scored                INTEGER,
       blocked_cross                    INTEGER,
       blocked_pass                     INTEGER,
       blocked_scoring_att              INTEGER,
       challenge_lost                   INTEGER,
       clean_sheet                      INTEGER,
       clearance_off_line               INTEGER,
       corner_taken                     INTEGER,
       cross_not_claimed                INTEGER,
       crosses_18yard                   INTEGER,
       crosses_18yardplus               INTEGER,
       dangerous_play                   INTEGER,
       dispossessed                     INTEGER,
       dive_catch                       INTEGER,
       dive_save                        INTEGER,
       diving_save                      INTEGER,
       duel_lost                        INTEGER,
       duel_won                         INTEGER,
       effective_blocked_cross          INTEGER,
       effective_clearance              INTEGER,
       effective_head_clearance         INTEGER,
       error_lead_to_goal               INTEGER,
       error_lead_to_shot               INTEGER,
       final_third_entries              INTEGER,
       first_half_goals                 INTEGER,
       formation_place                  INTEGER,
       formation_used                   INTEGER,
       foul_throw_in                    INTEGER,
       fouled_final_third               INTEGER,
       fouls                            INTEGER,
       freekick_cross                   INTEGER,
       fwd_pass                         INTEGER,
       game_started                     INTEGER,
       gk_smother                       INTEGER,
       goal_assist                      INTEGER,
       goal_assist_deadball             INTEGER,
       goal_assist_intentional          INTEGER,
       goal_assist_openplay             INTEGER,
       goal_assist_setplay              INTEGER,
       goal_fastbreak                   INTEGER,
       goal_kicks                       INTEGER,
       goals                            INTEGER,
       goals_conceded                   INTEGER,
       goals_conceded_ibox              INTEGER,
       goals_conceded_obox              INTEGER,
       goals_openplay                   INTEGER,
       good_high_claim                  INTEGER,
       hand_ball                        INTEGER,
       head_clearance                   INTEGER,
       head_pass                        INTEGER,
       hit_woodwork                     INTEGER,
       interception                     INTEGER,
       interception_won                 INTEGER,
       interceptions_in_box             INTEGER,
       keeper_pick_up                   INTEGER,
       keeper_throws                    INTEGER,
       last_man_tackle                  INTEGER,
       leftside_pass                    INTEGER,
       long_pass_own_to_opp             INTEGER,
       long_pass_own_to_opp_success     INTEGER,
       lost_corners                     INTEGER,
       mins_played                      INTEGER,
       offside_provoked                 INTEGER,
       offtarget_att_assist             INTEGER,
       ontarget_att_assist              INTEGER,
       ontarget_scoring_att             INTEGER,
       open_play_pass                   INTEGER,
       outfielder_block                 INTEGER,
       overrun                          INTEGER,
       own_goals                        INTEGER,
       passes_left                      INTEGER,
       passes_right                     INTEGER,
       pen_area_entries                 INTEGER,
       pen_goals_conceded               INTEGER,
       penalty_conceded                 INTEGER,
       penalty_faced                    INTEGER,
       penalty_save                     INTEGER,
       penalty_won                      INTEGER,
       poss_lost_all                    INTEGER,
       poss_lost_ctrl                   INTEGER,
       poss_won_att_3rd                 INTEGER,
       poss_won_def_3rd                 INTEGER,
       poss_won_mid_3rd                 INTEGER,
       post_scoring_att                 INTEGER,
       pts_dropped_winning_pos          INTEGER,
       pts_gained_losing_pos            INTEGER,
       punches                          INTEGER,
       put_through                      INTEGER,
       red_card                         INTEGER,
       rightside_pass                   INTEGER,
       saved_ibox                       INTEGER,
       saved_obox                       INTEGER,
       saves                            INTEGER,
       second_goal_assist               INTEGER,
       second_yellow                    INTEGER,
       shield_ball_oop                  INTEGER,
       shot_fastbreak                   INTEGER,
       shot_off_target                  INTEGER,
       six_second_violation             INTEGER,
       six_yard_block                   INTEGER,
       stand_catch                      INTEGER,
       stand_save                       INTEGER,
       successful_final_third_passes    INTEGER,
       successful_open_play_pass        INTEGER,
       successful_put_through           INTEGER,
       total_att_assist                 INTEGER,
       total_back_zone_pass             INTEGER,
       total_chipped_pass               INTEGER,
       total_clearance                  INTEGER,
       total_contest                    INTEGER,
       total_corners_intobox            INTEGER,
       total_cross                      INTEGER,
       total_cross_nocorner             INTEGER,
       total_fastbreak                  INTEGER,
       total_final_third_passes         INTEGER,
       total_flick_on                   INTEGER,
       total_fwd_zone_pass              INTEGER,
       total_high_claim                 INTEGER,
       total_keeper_sweeper             INTEGER,
       total_launches                   INTEGER,
       total_layoffs                    INTEGER,
       total_long_balls                 INTEGER,
       total_offside                    INTEGER,
       total_pass                       INTEGER,
       total_pull_back                  INTEGER,
       total_scoring_att                INTEGER,
       total_sub_off                    INTEGER,
       total_sub_on                     INTEGER,
       total_tackle                     INTEGER,
       total_through_ball               INTEGER,
       total_throws                     INTEGER,
       touches                          INTEGER,
       touches_in_opp_box               INTEGER,
       turnover                         INTEGER,
       unsuccessful_touch               INTEGER,
       was_fouled                       INTEGER,
       won_contest                      INTEGER,
       won_corners                      INTEGER,
       won_tackle                       INTEGER,
       yellow_card                      INTEGER
);

CREATE TABLE IF NOT EXISTS team_results (
       id                               SERIAL PRIMARY KEY,
       team_id                          INTEGER REFERENCES teams(id),
       side                             TEXT,
       score                            INTEGER,
       match_id                         INTEGER REFERENCES matches(id),
       competition_id                   INTEGER REFERENCES competitions(id),
       season_id                        INTEGER REFERENCES seasons(id),
       accurate_back_zone_pass          INTEGER,
       accurate_chipped_pass            INTEGER,
       accurate_corners_intobox         INTEGER,
       accurate_cross                   INTEGER,
       accurate_cross_nocorner          INTEGER,
       accurate_flick_on                INTEGER,
       accurate_freekick_cross          INTEGER,
       accurate_fwd_zone_pass           INTEGER,
       accurate_goal_kicks              INTEGER,
       accurate_keeper_sweeper          INTEGER,
       accurate_keeper_throws           INTEGER,
       accurate_launches                INTEGER,
       accurate_layoffs                 INTEGER,
       accurate_long_balls              INTEGER,
       accurate_pass                    INTEGER,
       accurate_pull_back               INTEGER,
       accurate_through_ball            INTEGER,
       accurate_throws                  INTEGER,
       aerial_lost                      INTEGER,
       aerial_won                       INTEGER,
       att_assist_openplay              INTEGER,
       att_assist_setplay               INTEGER,
       att_bx_centre                    INTEGER,
       att_bx_left                      INTEGER,
       att_bx_right                     INTEGER,
       att_cmiss_high                   INTEGER,
       att_cmiss_high_left              INTEGER,
       att_cmiss_high_right             INTEGER,
       att_cmiss_left                   INTEGER,
       att_cmiss_right                  INTEGER,
       att_fastbreak                    INTEGER,
       att_freekick_goal                INTEGER,
       att_freekick_miss                INTEGER,
       att_freekick_post                INTEGER,
       att_freekick_target              INTEGER,
       att_freekick_total               INTEGER,
       att_goal_high_centre             INTEGER,
       att_goal_high_left               INTEGER,
       att_goal_high_right              INTEGER,
       att_goal_low_centre              INTEGER,
       att_goal_low_left                INTEGER,
       att_goal_low_right               INTEGER,
       att_hd_goal                      INTEGER,
       att_hd_miss                      INTEGER,
       att_hd_post                      INTEGER,
       att_hd_target                    INTEGER,
       att_hd_total                     INTEGER,
       att_ibox_blocked                 INTEGER,
       att_ibox_goal                    INTEGER,
       att_ibox_miss                    INTEGER,
       att_ibox_own_goal                INTEGER,
       att_ibox_post                    INTEGER,
       att_ibox_target                  INTEGER,
       att_lf_goal                      INTEGER,
       att_lf_target                    INTEGER,
       att_lf_total                     INTEGER,
       att_lg_centre                    INTEGER,
       att_lg_left                      INTEGER,
       att_lg_right                     INTEGER,
       att_miss_high                    INTEGER,
       att_miss_high_left               INTEGER,
       att_miss_high_right              INTEGER,
       att_miss_left                    INTEGER,
       att_miss_right                   INTEGER,
       att_obox_blocked                 INTEGER,
       att_obox_goal                    INTEGER,
       att_obox_miss                    INTEGER,
       att_obox_own_goal                INTEGER,
       att_obox_post                    INTEGER,
       att_obox_target                  INTEGER,
       att_obp_goal                     INTEGER,
       att_obx_centre                   INTEGER,
       att_obx_left                     INTEGER,
       att_obx_right                    INTEGER,
       att_obxd_left                    INTEGER,
       att_obxd_right                   INTEGER,
       att_one_on_one                   INTEGER,
       att_openplay                     INTEGER,
       att_pen_goal                     INTEGER,
       att_pen_miss                     INTEGER,
       att_pen_post                     INTEGER,
       att_pen_target                   INTEGER,
       att_post_high                    INTEGER,
       att_post_left                    INTEGER,
       att_post_right                   INTEGER,
       att_rf_goal                      INTEGER,
       att_rf_target                    INTEGER,
       att_rf_total                     INTEGER,
       att_setpiece                     INTEGER,
       att_sv_high_centre               INTEGER,
       att_sv_high_left                 INTEGER,
       att_sv_high_right                INTEGER,
       att_sv_low_centre                INTEGER,
       att_sv_low_left                  INTEGER,
       att_sv_low_right                 INTEGER,
       attempted_tackle_foul            INTEGER,
       attempts_conceded_ibox           INTEGER,
       attempts_conceded_obox           INTEGER,
       backward_pass                    INTEGER,
       ball_recovery                    INTEGER,
       big_chance_created               INTEGER,
       big_chance_missed                INTEGER,
       big_chance_scored                INTEGER,
       blocked_cross                    INTEGER,
       blocked_pass                     INTEGER,
       blocked_scoring_att              INTEGER,
       challenge_lost                   INTEGER,
       clearance_off_line               INTEGER,
       contentious_decision             INTEGER,
       corner_taken                     INTEGER,
       crosses_18yard                   INTEGER,
       crosses_18yardplus               INTEGER,
       defender_goals                   INTEGER,
       dispossessed                     INTEGER,
       diving_save                      INTEGER,
       duel_lost                        INTEGER,
       duel_won                         INTEGER,
       effective_blocked_cross          INTEGER,
       effective_clearance              INTEGER,
       effective_head_clearance         INTEGER,
       error_lead_to_goal               INTEGER,
       error_lead_to_shot               INTEGER,
       final_third_entries              INTEGER,
       fk_foul_lost                     INTEGER,
       fk_foul_won                      INTEGER,
       forward_goals                    INTEGER,
       foul_throw_in                    INTEGER,
       fouled_final_third               INTEGER,
       freekick_cross                   INTEGER,
       fwd_pass                         INTEGER,
       goal_assist                      INTEGER,
       goal_assist_deadball             INTEGER,
       goal_assist_intentional          INTEGER,
       goal_assist_openplay             INTEGER,
       goal_assist_setplay              INTEGER,
       goal_fastbreak                   INTEGER,
       goal_kicks                       INTEGER,
       goals                            INTEGER,
       goals_conceded                   INTEGER,
       goals_conceded_ibox              INTEGER,
       goals_conceded_obox              INTEGER,
       goals_openplay                   INTEGER,
       good_high_claim                  INTEGER,
       hand_ball                        INTEGER,
       head_clearance                   INTEGER,
       hit_woodwork                     INTEGER,
       interception                     INTEGER,
       interception_won                 INTEGER,
       interceptions_in_box             INTEGER,
       keeper_throws                    INTEGER,
       last_man_tackle                  INTEGER,
       leftside_pass                    INTEGER,
       long_pass_own_to_opp             INTEGER,
       long_pass_own_to_opp_success     INTEGER,
       lost_corners                     INTEGER,
       midfielder_goals                 INTEGER,
       offtarget_att_assist             INTEGER,
       ontarget_att_assist              INTEGER,
       ontarget_scoring_att             INTEGER,
       open_play_pass                   INTEGER,
       outfielder_block                 INTEGER,
       overrun                          INTEGER,
       own_goal_accrued                 INTEGER,
       own_goals                        INTEGER,
       passes_left                      INTEGER,
       passes_right                     INTEGER,
       pen_area_entries                 INTEGER,
       pen_goals_conceded               INTEGER,
       penalty_conceded                 INTEGER,
       penalty_faced                    INTEGER,
       penalty_save                     INTEGER,
       penalty_won                      INTEGER,
       poss_lost_all                    INTEGER,
       poss_lost_ctrl                   INTEGER,
       poss_won_att_3rd                 INTEGER,
       poss_won_def_3rd                 INTEGER,
       poss_won_mid_3rd                 INTEGER,
       possession_percentage            FLOAT,
       post_scoring_att                 INTEGER,
       punches                          INTEGER,
       put_through                      INTEGER,
       rightside_pass                   INTEGER,
       saved_ibox                       INTEGER,
       saved_obox                       INTEGER,
       saves                            INTEGER,
       second_yellow                    INTEGER,
       shield_ball_oop                  INTEGER,
       shot_fastbreak                   INTEGER,
       shot_off_target                  INTEGER,
       six_yard_block                   INTEGER,
       subs_made                        INTEGER,
       successful_final_third_passes    INTEGER,
       successful_open_play_pass        INTEGER,
       successful_put_through           INTEGER,
       total_att_assist                 INTEGER,
       total_back_zone_pass             INTEGER,
       total_chipped_pass               INTEGER,
       total_clearance                  INTEGER,
       total_contest                    INTEGER,
       total_corners_intobox            INTEGER,
       total_cross                      INTEGER,
       total_cross_nocorner             INTEGER,
       total_fastbreak                  INTEGER,
       total_final_third_passes         INTEGER,
       total_flick_on                   INTEGER,
       total_fwd_zone_pass              INTEGER,
       total_high_claim                 INTEGER,
       total_keeper_sweeper             INTEGER,
       total_launches                   INTEGER,
       total_layoffs                    INTEGER,
       total_long_balls                 INTEGER,
       total_offside                    INTEGER,
       total_pass                       INTEGER,
       total_pull_back                  INTEGER,
       total_red_card                   INTEGER,
       total_scoring_att                INTEGER,
       total_tackle                     INTEGER,
       total_through_ball               INTEGER,
       total_throws                     INTEGER,
       total_yel_card                   INTEGER,
       touches                          INTEGER,
       touches_in_opp_box               INTEGER,
       unsuccessful_touch               INTEGER,
       won_contest                      INTEGER,
       won_corners                      INTEGER,
       won_tackle                       INTEGER
);
