#' Polynomial Dissimilarity Distance
#'
#' Compares polynomials relating to the eigenvalues of the adjacency matrices
#'
#' @param graph_1 igraph or matrix object.
#' @param graph_2 igraph or matrix object.
#' @param k Numeric maximum degree of the polynomial.
#' @param alpha Numeric weighting factor.
#'
#' @return A numeric polynomial dissimilarity between graph_1, graph_2
#'   in a structure dist
#'
#' @export
dist_polynomial_dissimilarity <- function(graph_1, graph_2, k = 5, alpha = 1) UseMethod("dist_polynomial_dissimilarity")

#' @export
dist_polynomial_dissimilarity.igraph <- function(graph_1, graph_2, k = 5, alpha = 1) {
  assertthat::assert_that(
    all(igraph::is.igraph(graph_1), igraph::is.igraph(graph_2)),
    msg = "Graphs must be igraph objects."
  )

  dist_polynomial_dissimilarity.matrix(
    igraph::as_adj(graph_1, sparse = FALSE),
    igraph::as_adj(graph_2, sparse = FALSE),
    k,
    alpha
  )
}

#' @export
dist_polynomial_dissimilarity.matrix <- function(graph_1, graph_2, k = 5, alpha = 1) {
  assertthat::assert_that(
    all(is.matrix(graph_1), is.matrix(graph_2)),
    msg = "Graphs must be adjacency matrices."
  )

  A1 <- graph_1
  A2 <- graph_2

  P_A1 <- similarity_score(A1, k, alpha)
  P_A2 <- similarity_score(A2, k, alpha)
  difference <- P_A1 - P_A2

  currDist <- norm(difference, type = c("F")) / nrow(A1)**2

  structure(
    list(
      adjacency_matrices = c(graph_1, graph_2),
      dist = currDist
    ),
    class = "polynomial_dissimilarity"
  )
}

similarity_score <- function(A, k, alpha) {
  e <- eigen(A)
  eig_vals <- e$values
  Q <- e$vectors
  c <- ncol(A)
  n <- nrow(A)

  x <- sapply(0:k + 1, function(kp) {
    (eig_vals**kp) / ((n - 1) ** (alpha * (kp - 1)))
  })

  sumAllRows <- (rowSums(x))

  W <- diag(sumAllRows, n, c)
  (Q %*% W) %*% t(Q)
}
