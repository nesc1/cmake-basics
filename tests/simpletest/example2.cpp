#include <gtest/gtest.h>
#include <mylibA/mylibA_header.h>

TEST(Two, Negative) {
    EXPECT_EQ(-1, -1);
}
TEST(Two, GoodMath) {
    EXPECT_EQ(doTheMath(1111, 1), 101);
}