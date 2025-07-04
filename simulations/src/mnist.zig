const std = @import("std");
const img = @import("zigimg");
const data_point = @import("datapoint.zig");
const readFile = @import("utils.zig").readFile;

pub fn free_mnist_data_points_soa(allocator: std.mem.Allocator, soa: data_point.DataPointSOA) void {
    allocator.free(soa.x);
    allocator.free(soa.y);
}

/// Assumed to be the same length
fn copy_image_data(input: []const u8, output: []f64) void {
    for (input, 0..) |pixel, i| {
        const x_val = @as(f64, @floatFromInt(pixel));
        // normalize
        output[i] = x_val / 255;
    }
}

/// Need to call `free_mnist_data_points_soa`
pub fn make_mnist_data_points_soa(allocator: std.mem.Allocator, x: []const u8, x_chunk_size: usize, y: []const u8, y_output_size: usize) !data_point.DataPointSOA {
    const x_data = try allocator.alloc(f64, x.len);
    const y_data = try allocator.alloc(f64, y.len * y_output_size);
    const result = data_point.DataPointSOA{
        .x = x_data,
        .x_chunk_size = x_chunk_size,
        .y_chunk_size = y_output_size,
        .y = y_data,
    };
    var idx: usize = 0;
    const total = x.len / x_chunk_size;
    while (idx < total) : (idx += 1) {
        const i = idx * x_chunk_size;
        const x_chunk = x[i .. i + x_chunk_size];
        const x_buffer = result.x[i .. i + x_chunk_size];
        copy_image_data(x_chunk, x_buffer);
        const y_index = idx * result.y_chunk_size;
        const y_buffer = result.y[y_index .. y_index + result.y_chunk_size];
        write_digit(y[idx], y_buffer);
    }
    return result;
}

/// Writes the decimal digit 0-9 to a buffer
/// of size 10, where the value at the position
/// corresponds to whether the current digit
/// is represented.
///
/// For example, `4` is represented as
///
/// ```
/// [0, 0, 0, 0, 1, 0, 0, 0, 0, 0]
///  0  1  2  3  4  5  6  7  8  9
/// ```
fn write_digit(digit: u8, buf: []f64) void {
    // clear all
    for (buf, 0..) |_, i| {
        buf[i] = 0;
    }
    buf[digit] = 1;
}

pub fn run(allocator: std.mem.Allocator) void {

    // const TRAIN_LABELS_FILE = "data/train-labels.idx1-ubyte";
    // const train_labels_buffer = try readFile(allocator, TRAIN_LABELS_FILE);
    // defer allocator.free(train_labels_buffer);

    // read training labels
    // const start_index = 8;
    // const labels = train_labels_buffer[start_index..];

    // read training images
    const TRAIN_IMAGES_FILE = "data/train-images.idx3-ubyte";
    const train_images_buffer = try readFile(allocator, TRAIN_IMAGES_FILE);
    defer allocator.free(train_images_buffer);

    // can read image count from file, but should be exactly the same as labels
    // const img_start_offset = 16;
    // const images = train_images_buffer[img_start_offset..];

    // read test images
    const TEST_IMAGES_FILE = "data/t10k-images.idx3-ubyte";
    const test_images_buffer = try readFile(allocator, TEST_IMAGES_FILE);
    defer allocator.free(test_images_buffer);
    // const test_images = test_images_buffer[img_start_offset..];

    // read test labels
    // const TEST_LABELS_FILE = "data/t10k-labels.idx1-ubyte";
    // const test_labels_buffer = try readFile(allocator, TEST_LABELS_FILE);
    // defer allocator.free(test_labels_buffer);
    // const test_labels = test_labels_buffer[start_index..];

    // const image_size: comptime_int = 28 * 28;

    // const DIGITS = 10;
    std.debug.print("making training data points...", .{});
    // const train_data_points = try mnist.make_mnist_data_points_soa(allocator, images, image_size, labels, DIGITS);
    // defer mnist.free_mnist_data_points_soa(allocator, train_data_points);
    // std.debug.print("made {} train data points.\n", .{train_data_points.len()});

    std.debug.print("making test data points...", .{});
    // const test_data = try mnist.make_mnist_data_points_soa(allocator, test_images, image_size, test_labels, DIGITS);
    // defer mnist.free_mnist_data_points_soa(allocator, test_data);
    // std.debug.print("made {} test data points.\n", .{test_data.len()}); // Process both original (on-center) and negative (off-center) images
}
