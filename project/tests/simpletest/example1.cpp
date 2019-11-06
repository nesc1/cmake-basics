#include <gtest/gtest.h>
#include <mylibA/mylibA_header.h>

TEST(One, EqualsOne) {
    EXPECT_EQ(1, 1);
}

TEST(One, GoodMath) {
    EXPECT_EQ(doTheMath(1, 1), 2);
}