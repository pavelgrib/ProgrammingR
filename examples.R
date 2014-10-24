df <- read.csv('rTutorial/data.csv')
colnames(df) <- c("date", "mid", "sid", "clicks", "orders", "gms")
df$date <- as.Date(df$date, format = "%d-%b-%y")

str(df)

summary(df)

model <- lm(log(gms) ~ log(orders) + log(clicks), df, (mid == 3184) & (orders > 0))
summary(model)
plot(model$fitted.values, model$residuals)

splitFrame <- function(frame) {
  frame$highGMS = FALSE
  for(i in 1:nrow(frame)) {
    if(frame$gms > 10000) {
      frame$highGMS[i] = TRUE
    }
  }
  return(frame)
}

require(plyr)
grouped1 <- ddply(.data = df, .variables = .(mid), .fun = summarize, avg_gms = mean(gms), max_orders = max(orders))
str(grouped1)
grouped2 <- ddply(.data = df, .variables = .(mid, sid), .fun = summarize,
                  avg_gms = mean(gms), max_orders = max(orders), avg_order = sum(gms) / sum(orders))
grouped2$is_big <- grouped2$avg_gms > 1000
grouped2 <- grouped2[!is.na(grouped2$avg_order),]
str(grouped2)

require(ggplot2)

g <- ggplot(data = grouped2, aes(max_orders, avg_order, color = factor(mid)))
g + geom_point() + ggtitle("Max Orders vs Avg GMS")
g + geom_point() + ggtitle("Max Orders vs Avg GMS") + xlim(c(10, 100)) + ylim(c(10, 100))

g <- ggplot(data = grouped2, aes(avg_order, color = factor(is_big)))
g + geom_histogram() #+ xlim(c(0, 1000))


