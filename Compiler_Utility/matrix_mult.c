#include <stdio.h>

#define ROW1 2 // Rows of first matrix
#define COL1 3 // Columns of first matrix (must be equal to ROW2)
#define ROW2 3 // Rows of second matrix (must be equal to COL1)
#define COL2 2 // Columns of second matrix

void print_matrix(int rows, int cols, int matrix[][cols], const char* name) {
    printf("\nMatrix %s (%dx%d):\n", name, rows, cols);
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%4d ", matrix[i][j]);
        }
        printf("\n");
    }
}

int main() {
    printf("--- RV32I Matrix Multiplication Example ---\n");

    // Define two matrices
    int matrix1[ROW1][COL1] = {
        {1, 2, 3},
        {4, 5, 6}
    };

    int matrix2[ROW2][COL2] = {
        {7, 8},
        {9, 1},
        {2, 3}
    };

    // Resultant matrix will have dimensions ROW1 x COL2
    int result_matrix[ROW1][COL2];

    // Initialize result matrix with zeros
    for (int i = 0; i < ROW1; i++) {
        for (int j = 0; j < COL2; j++) {
            result_matrix[i][j] = 0;
        }
    }

    // Print input matrices - arguments are now (rows, cols, matrix, name)
    print_matrix(ROW1, COL1, matrix1, "A");
    print_matrix(ROW2, COL2, matrix2, "B"); // ROW2=3, COL2=2

    // Perform matrix multiplication
    printf("\nPerforming Matrix Multiplication (A x B)...\n");
    for (int i = 0; i < ROW1; i++) { // Iterate over rows of matrix1
        for (int j = 0; j < COL2; j++) { // Iterate over columns of matrix2
            for (int k = 0; k < COL1; k++) { // Iterate over columns of matrix1 (or rows of matrix2)
                result_matrix[i][j] += matrix1[i][k] * matrix2[k][j];
            }
        }
    }

    // Print the result matrix
    print_matrix(ROW1, COL2, result_matrix, "Result (A x B)"); // ROW1=2, COL2=2

    printf("\n--- Program End ---\n");

    return 0;
}
