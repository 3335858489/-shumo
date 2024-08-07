function best_Route = simulated_annealing(city_num, railway_time, spot_time, T)
    % 初始化参数
    current_solution = randperm(city_num);
    best_solution = current_solution;
    current_time = calculate_total_time(current_solution, railway_time, spot_time);
    best_time = current_time;
    temperature = 1000;
    cooling_rate = 0.99;

    while temperature > 1
        % 生成新解
        new_solution = current_solution;
        idx = randperm(city_num, 2);
        new_solution(idx) = new_solution(fliplr(idx));
        new_time = calculate_total_time(new_solution, railway_time, spot_time);

        % 接受新解的概率
        if new_time < current_time || exp((current_time - new_time) / temperature) > rand
            current_solution = new_solution;
            current_time = new_time;
        end

        % 更新最佳解
        if current_time < best_time
            best_solution = current_solution;
            best_time = current_time;
        end

        % 降温
        temperature = temperature * cooling_rate;
    end

    best_Route = best_solution;
end

function total_time = calculate_total_time(route, railway_time, spot_time)
    total_time = 0;
    for i = 1:length(route)
        total_time = total_time + spot_time(route(i));
        if i > 1
            total_time = total_time + railway_time(route(i-1), route(i));
        end
    end
end