function[y] = normal_distribution(x, mu, sigma)
    
    y = exp(-(x - mu).^2/(2*sigma^2))/sqrt(2*pi*sigma^2);

end