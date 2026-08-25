library(shiny)

ui <- fluidPage(
  titlePanel("Law of Large Numbers & Central Limit Theorem Visualizer"),
  sidebarLayout(
    sidebarPanel(
      # 1. Population Proportion p
      numericInput("p", "Population Proportion (p):", value = 0.5, min = 0, max = 1, step = 0.05),
      checkboxInput("show_p", "Show p (Horizontal Line)", value = TRUE),
      hr(),
      
      # 2. Maximal Sample Size n
      numericInput("n", "Maximal Sample Size (n):", value = 100, min = 5, step = 10),
      hr(),
      
      # 3. Confidence Intervals
      checkboxInput("show_ci", "Show Confidence Interval", value = FALSE),
      numericInput("alpha", "Significance Level (alpha):", value = 0.05, min = 0.001, max = 0.5, step = 0.01),
      hr(),
      
      # 4. Number of Trajectories N
      numericInput("N", "Number of Samples/Paths (N):", value = 100, min = 1, max = 1000, step = 10),
      hr(),
      
      # 5. Normal Approximation
      checkboxInput("show_norm", "Show Normal Approximation at n", value = FALSE),
      hr(),
      helpText("Tip: Click & drag a box on the plot to zoom in on the histogram at x = n. Double-click to reset view.")
    ),
    
    mainPanel(
      plotOutput("llnPlot", height = "550px",
                 dblclick = "llnPlot_dblclick",
                 brush = brushOpts(id = "llnPlot_brush", resetOnNew = TRUE))
    )
  )
)

server <- function(input, output, session) {
  
  # Reactive values for zoom range
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  # Double-click to reset zoom
  observeEvent(input$llnPlot_dblclick, {
    ranges$x <- NULL
    ranges$y <- NULL
  })
  
  # Brush event to set zoom window
  observeEvent(input$llnPlot_brush, {
    brush <- input$llnPlot_brush
    if (!is.null(brush)) {
      ranges$x <- c(brush$xmin, brush$xmax)
      ranges$y <- c(brush$ymin, brush$ymax)
    }
  })
  
  observeEvent(input$p, {
    showNotification("Population proportion 'p' changed: Regenerating sample data.", type = "warning", duration = 3)
  }, ignoreInit = TRUE)
  
  observeEvent(input$n, {
    showNotification("Sample size 'n' changed: Regenerating sample data.", type = "warning", duration = 3)
  }, ignoreInit = TRUE)
  
  sample_data <- reactive({
    req(input$p, input$n, input$N)
    p <- input$p
    n <- input$n
    N <- input$N
    
    raw_data <- matrix(rbinom(n * N, size = 1, prob = p), nrow = n, ncol = N)
    apply(raw_data, 2, function(col) cumsum(col) / (1:n))
  })
  
  output$llnPlot <- renderPlot({
    mat <- sample_data()
    n <- input$n
    p <- input$p
    alpha <- input$alpha
    N <- input$N
    
    # Determine zoom limits
    x_lim <- if (!is.null(ranges$x)) ranges$x else c(1, n)
    y_lim <- if (!is.null(ranges$y)) ranges$y else c(0, 1)
    
    plot(1, type = "n", xlim = x_lim, ylim = y_lim,
         xlab = "Sample Size (k)", ylab = "Sample Proportion",
         main = paste("Running Sample Proportion for N =", N, "Sample Path(s)"))
    grid()
    
    # --- Compute Density-Based Colors for Paths ---
    final_vals <- mat[n, ]
    val_range <- range(final_vals)
    
    if (val_range[1] == val_range[2]) {
      breaks_seq <- seq(max(0, val_range[1] - 0.05), min(1, val_range[1] + 0.05), length.out = 10)
    } else {
      n_bins <- max(12, min(35, round(sqrt(N) * 1.2)))
      buf <- (val_range[2] - val_range[1]) * 0.02
      breaks_seq <- seq(val_range[1] - buf, val_range[2] + buf, length.out = n_bins + 1)
    }
    
    # Bin each path's terminal value at x = n
    bin_indices <- cut(final_vals, breaks = breaks_seq, include.lowest = TRUE, labels = FALSE)
    bin_counts <- tabulate(bin_indices, nbins = length(breaks_seq) - 1)
    path_counts <- bin_counts[bin_indices]
    
    # Map bin counts to color gradient (light blue -> navy blue)
    min_c <- min(path_counts, na.rm = TRUE)
    max_c <- max(path_counts, na.rm = TRUE)
    
    if (max_c == min_c) {
      path_cols <- rep("#3182bd", N)
    } else {
      norm_counts <- (path_counts - min_c) / (max_c - min_c)
      color_palette <- colorRampPalette(c("#bdd7e7", "#3182bd", "#08306b"))
      colors_100 <- color_palette(100)
      path_cols <- colors_100[pmin(100, pmax(1, round(norm_counts * 99) + 1))]
    }
    
    # Draw individual trajectories with density-based color
    for (j in 1:ncol(mat)) {
      lines(1:n, mat[, j], col = path_cols[j], lwd = 1.2)
    }
    
    # Pooled CI across all N paths
    if (input$show_ci) {
      k <- 1:n
      p_hat_pooled <- rowMeans(mat)
      z <- qnorm(1 - alpha / 2)
      se_pooled <- sqrt(p_hat_pooled * (1 - p_hat_pooled) / (N * k))
      
      ci_lower <- pmax(0, p_hat_pooled - z * se_pooled)
      ci_upper <- pmin(1, p_hat_pooled + z * se_pooled)
      
      lines(k, ci_lower, col = "black", lty = 2, lwd = 2)
      lines(k, ci_upper, col = "black", lty = 2, lwd = 2)
    }
    
    # Empirical Histogram + Theoretical Normal Density Overlay
    if (input$show_norm) {
      max_width <- 0.15 * n
      sigma <- sqrt(p * (1 - p) / n)
      norm_peak <- if (sigma > 0) 1 / (sigma * sqrt(2 * pi)) else 1
      scale_factor <- max_width / norm_peak
      
      h <- hist(final_vals, breaks = breaks_seq, plot = FALSE)
      
      # Draw empirical density histogram
      if (max(h$density) > 0) {
        for (i in seq_along(h$counts)) {
          if (h$counts[i] > 0) {
            bar_len <- h$density[i] * scale_factor
            rect(xleft = n - bar_len,
                 ybottom = h$breaks[i],
                 xright = n,
                 ytop = h$breaks[i + 1],
                 col = rgb(0.7, 0.7, 0.7, 0.5),
                 border = "gray40")
          }
        }
      }
      
      # Overlay theoretical Normal density curve
      if (sigma > 0) {
        y_vals <- seq(max(0, p - 4 * sigma), min(1, p + 4 * sigma), length.out = 300)
        dens <- dnorm(y_vals, mean = p, sd = sigma)
        x_vals <- n - (dens * scale_factor)
        
        polygon(c(rep(n, length(y_vals)), rev(x_vals)),
                c(y_vals, rev(y_vals)),
                col = rgb(0.2, 0.4, 0.8, 0.25),
                border = "blue",
                lwd = 2)
      }
      abline(v = n, col = "blue", lty = 4)
    }
    
    if (input$show_p) {
      abline(h = p, col = "red", lwd = 2, lty = 2)
    }
  })
}

shinyApp(ui = ui, server = server) 

# 
# library(shiny)
# 
# ui <- fluidPage(
#   titlePanel("Law of Large Numbers & Central Limit Theorem Visualizer"),
#   sidebarLayout(
#     sidebarPanel(
#       # 1. Population Proportion p
#       numericInput("p", "Population Proportion (p):", value = 0.5, min = 0, max = 1, step = 0.05),
#       checkboxInput("show_p", "Show p (Horizontal Line)", value = TRUE),
#       hr(),
#       
#       # 2. Maximal Sample Size n
#       numericInput("n", "Maximal Sample Size (n):", value = 100, min = 5, step = 10),
#       hr(),
#       
#       # 3. Confidence Intervals
#       checkboxInput("show_ci", "Show Confidence Interval", value = FALSE),
#       numericInput("alpha", "Significance Level (alpha):", value = 0.05, min = 0.001, max = 0.5, step = 0.01),
#       hr(),
#       
#       # 4. Number of Trajectories N
#       numericInput("N", "Number of Samples/Paths (N):", value = 1, min = 1, max = 1000, step = 10),
#       hr(),
#       
#       # 5. Normal Approximation
#       checkboxInput("show_norm", "Show Normal Approximation at n", value = FALSE)
#     ),
#     
#     mainPanel(
#       plotOutput("llnPlot", height = "550px")
#     )
#   )
# )
# 
# server <- function(input, output, session) {
#   
#   observeEvent(input$p, {
#     showNotification("Population proportion 'p' changed: Regenerating sample data.", type = "warning", duration = 3)
#   }, ignoreInit = TRUE)
#   
#   observeEvent(input$n, {
#     showNotification("Sample size 'n' changed: Regenerating sample data.", type = "warning", duration = 3)
#   }, ignoreInit = TRUE)
#   
#   sample_data <- reactive({
#     req(input$p, input$n, input$N)
#     p <- input$p
#     n <- input$n
#     N <- input$N
#     
#     raw_data <- matrix(rbinom(n * N, size = 1, prob = p), nrow = n, ncol = N)
#     apply(raw_data, 2, function(col) cumsum(col) / (1:n))
#   })
#   
#   output$llnPlot <- renderPlot({
#     mat <- sample_data()
#     n <- input$n
#     p <- input$p
#     alpha <- input$alpha
#     N <- input$N
#     
#     plot(1, type = "n", xlim = c(1, n), ylim = c(0, 1),
#          xlab = "Sample Size (k)", ylab = "Sample Proportion",
#          main = paste("Running Sample Proportion for N =", N, "Sample Path(s)"))
#     grid()
#     
#     cols <- rainbow(ncol(mat), alpha = 0.6)
#     for (j in 1:ncol(mat)) {
#       lines(1:n, mat[, j], col = cols[j], lwd = 1)
#     }
#     
#     # Pooled CI across all N paths
#     if (input$show_ci) {
#       k <- 1:n
#       p_hat_pooled <- rowMeans(mat)
#       z <- qnorm(1 - alpha / 2)
#       se_pooled <- sqrt(p_hat_pooled * (1 - p_hat_pooled) / (N * k))
#       
#       ci_lower <- pmax(0, p_hat_pooled - z * se_pooled)
#       ci_upper <- pmin(1, p_hat_pooled + z * se_pooled)
#       
#       lines(k, ci_lower, col = "black", lty = 2, lwd = 2)
#       lines(k, ci_upper, col = "black", lty = 2, lwd = 2)
#     }
#     
#     # Empirical Histogram + Theoretical Normal Density Overlay
#     if (input$show_norm) {
#       max_width <- 0.15 * n
#       final_vals <- mat[n, ]
#       
#       # Calculate theoretical standard deviation and peak density height
#       sigma <- sqrt(p * (1 - p) / n)
#       norm_peak <- if (sigma > 0) 1 / (sigma * sqrt(2 * pi)) else 1
#       scale_factor <- max_width / norm_peak
#       
#       # Zoom bin sequence strictly to the observed data range
#       val_range <- range(final_vals)
#       if (val_range[1] == val_range[2]) {
#         breaks_seq <- seq(max(0, val_range[1] - 0.05), min(1, val_range[1] + 0.05), length.out = 10)
#       } else {
#         # Scale bin count dynamically with N (e.g. 12 to 35 bins)
#         n_bins <- max(12, min(35, round(sqrt(N) * 1.2)))
#         buf <- (val_range[2] - val_range[1]) * 0.02
#         breaks_seq <- seq(val_range[1] - buf, val_range[2] + buf, length.out = n_bins + 1)
#       }
#       
#       h <- hist(final_vals, breaks = breaks_seq, plot = FALSE)
#       
#       # Draw empirical density histogram
#       if (max(h$density) > 0) {
#         for (i in seq_along(h$counts)) {
#           if (h$counts[i] > 0) {
#             bar_len <- h$density[i] * scale_factor
#             rect(xleft = n - bar_len,
#                  ybottom = h$breaks[i],
#                  xright = n,
#                  ytop = h$breaks[i + 1],
#                  col = rgb(0.7, 0.7, 0.7, 0.6),
#                  border = "gray40")
#           }
#         }
#       }
#       
#       # Overlay theoretical Normal density curve
#       if (sigma > 0) {
#         y_vals <- seq(max(0, p - 4 * sigma), min(1, p + 4 * sigma), length.out = 300)
#         dens <- dnorm(y_vals, mean = p, sd = sigma)
#         x_vals <- n - (dens * scale_factor)
#         
#         polygon(c(rep(n, length(y_vals)), rev(x_vals)),
#                 c(y_vals, rev(y_vals)),
#                 col = rgb(0.2, 0.4, 0.8, 0.25),
#                 border = "blue",
#                 lwd = 2)
#       }
#       abline(v = n, col = "blue", lty = 4)
#     }
#     
#     if (input$show_p) {
#       abline(h = p, col = "green", lwd = 2, lty = 2)
#     }
#   })
# }
# 
# shinyApp(ui = ui, server = server)