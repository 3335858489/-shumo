function best_Route = ant_colony_optimization(city_num, railway_time, spot_time, T)
    % 初始化参数
    num_ants = 50;
    max_iterations = 100;
    alpha = 1;
    beta = 5;
    evaporation_rate = 0.5;
    pheromone = ones(city_num);

    best_solution = [];
    best_time = inf;

    for iter = 1:max_iterations
        solutions = zeros(num_ants, city_num);
        times = zeros(num_ants, 1);

        for ant = 1:num_ants
            solutions(ant, :) = generate_solution(city_num, pheromone, alpha, beta, railway_time, spot_time, T);
            times(ant) = calculate_total_time(solutions(ant, :), railway_time, spot_time);
        end

        % 更新最佳解
        [min_time, min_idx] = min(times);
        if min_time < best_time
            best_solution = solutions(min_idx, :);
            best_time = min_time;
        end

        % 更新信息素
        pheromone = (1 - evaporation_rate) * pheromone;
        for ant = 1:num_ants
            for i = 1:(city_num - 1)
                pheromone(solutions(ant, i), solutions(ant, i+1)) = pheromone(solutions(ant, i), solutions(ant, i+1)) + 1 / times(ant);
            end
        end
    end

    best_Route = best_solution;
end

function solution = generate_solution(city_num, pheromone, alpha, beta, railway_time, spot_time, T)
    solution = zeros(1, city_num);
    visited = false(1, city_num);
    current_city = randi(city_num);
    solution(1) = current_city;
    visited(current_city) = true;

    for i = 2:city_num
        probabilities = (pheromone(current_city, :) .^ alpha) .* ((1 ./ railway_time(current_city, :)) .^ beta);
        probabilities(visited) = 0;
        probabilities = probabilities / sum(probabilities);
        next_city = find(rand < cumsum(probabilities), 1);
        solution(i) = next_city;
        visited(next_city) = true;
        current_city = next_city;
    end
end