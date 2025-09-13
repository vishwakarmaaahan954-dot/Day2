module MyModule::GameScoreTracker {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a player's game score and token rewards.
    struct PlayerScore has store, key {
        score: u64,        // Player's current game score
        tokens_earned: u64, // Total tokens earned from achievements
    }

    /// Function to initialize a new player's score tracking.
    public fun create_player(player: &signer) {
        let player_score = PlayerScore {
            score: 0,
            tokens_earned: 0,
        };
        move_to(player, player_score);
    }

    /// Function to update player's score and reward tokens based on achievement.
    /// Rewards 10 tokens for every 100 points scored.
    public fun update_score_and_reward(
        player: &signer, 
        game_master: &signer,
        points_gained: u64
    ) acquires PlayerScore {
        let player_addr = signer::address_of(player);
        let player_score = borrow_global_mut<PlayerScore>(player_addr);
        
        // Update player's score
        player_score.score = player_score.score + points_gained;
        
        // Calculate token rewards (10 tokens per 100 points)
        let token_reward = (points_gained / 100) * 10;
        
        if (token_reward > 0) {
            // Transfer tokens from game master to player
            let reward_coins = coin::withdraw<AptosCoin>(game_master, token_reward);
            coin::deposit<AptosCoin>(player_addr, reward_coins);
            
            // Update total tokens earned
            player_score.tokens_earned = player_score.tokens_earned + token_reward;
        }
    }

    /// Function to get player's current score and tokens earned.
    public fun get_player_stats(player_addr: address): (u64, u64) acquires PlayerScore {
        let player_score = borrow_global<PlayerScore>(player_addr);
        (player_score.score, player_score.tokens_earned)
    }
}