// RUN: tf-opt %s -split-input-file -verify-diagnostics -tf-tpu-update-embedding-enqueue-op-inputs | FileCheck %s

// CHECK-LABEL: func @check_enqueue_ops_update_for_eval
// CHECK-SAME: %[[ARG_0:[a-z0-9]*]]: tensor<?x2xi32>
// CHECK-SAME: %[[ARG_1:[a-z0-9]*]]: tensor<?x2xi32>
// CHECK-SAME: %[[ARG_2:[a-z0-9]*]]: tensor<?x2xi32>
// CHECK-SAME: %[[ARG_3:[a-z0-9]*]]: tensor<?xi32>
// CHECK-SAME: %[[ARG_4:[a-z0-9]*]]: tensor<?xi32>
// CHECK-SAME: %[[ARG_5:[a-z0-9]*]]: tensor<?xi32>
// CHECK-SAME: %[[ARG_6:[a-z0-9]*]]: tensor<!tf.string>
// CHECK-SAME: %[[ARG_7:[a-z0-9]*]]: tensor<!tf.string>
// CHECK-SAME: %[[ARG_8:[a-z0-9]*]]: tensor<i1>
func @check_enqueue_ops_update_for_eval(%arg0: tensor<?x2xi32>, %arg1: tensor<?x2xi32>,
  %arg2 :tensor<?x2xi32>, %arg3: tensor<?xi32>, %arg4: tensor<?xi32>, %arg5: tensor<?xi32>,
  %arg6: tensor<!tf.string>, %arg7: tensor<!tf.string>, %arg8: tensor<i1>) -> () {
  // CHECK: %[[CONST_0:[a-z0-9]*]] = "tf.Const"()
  %0 = "tf.Const"() {value = dense<[]> : tensor<0xf32>} : () -> tensor<0xf32>
  %1 = "tf.SelectV2"(%arg8, %arg6, %arg7) : (tensor<i1>, tensor<!tf.string>, tensor<!tf.string>) -> tensor<!tf.string>

  // CHECK: "tf.EnqueueTPUEmbeddingSparseTensorBatch"(%[[ARG_0]], %[[ARG_1]], %[[ARG_2]], %[[ARG_3]], %[[ARG_4]], %[[ARG_5]], %[[CONST_0]], %[[CONST_0]], %[[CONST_0]], %[[ARG_7]])
  "tf.EnqueueTPUEmbeddingSparseTensorBatch"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %0, %0, %0, %1) {_tpu_embedding_layer = "call1", _xla_outside_compilation = "0", combiners = ["mean", "sum"], device_ordinal = -1 : i64, max_sequence_lengths = [0, 0, 0], table_ids = [1, 1, 0]} : (tensor<?x2xi32>, tensor<?x2xi32>, tensor<?x2xi32>, tensor<?xi32>, tensor<?xi32>, tensor<?xi32>, tensor<0xf32>, tensor<0xf32>, tensor<0xf32>, tensor<!tf.string>) -> ()
  %2:2 = "tf.RecvTPUEmbeddingActivations"() {_tpu_embedding_layer = "call1", config = "\0A\0B\0C\0D"} : () -> (tensor<2x2xf32>, tensor<4x4xf32>)
  return
}

// -----

// CHECK-LABEL: func @check_enqueue_ops_update_for_training
// CHECK-SAME: %[[ARG_0:[a-z0-9]*]]: tensor<?x2xi32>
// CHECK-SAME: %[[ARG_1:[a-z0-9]*]]: tensor<?x2xi32>
// CHECK-SAME: %[[ARG_2:[a-z0-9]*]]: tensor<?x2xi32>
// CHECK-SAME: %[[ARG_3:[a-z0-9]*]]: tensor<?xi32>
// CHECK-SAME: %[[ARG_4:[a-z0-9]*]]: tensor<?xi32>
// CHECK-SAME: %[[ARG_5:[a-z0-9]*]]: tensor<?xi32>
// CHECK-SAME: %[[ARG_6:[a-z0-9]*]]: tensor<!tf.string>
// CHECK-SAME: %[[ARG_7:[a-z0-9]*]]: tensor<!tf.string>
// CHECK-SAME: %[[ARG_8:[a-z0-9]*]]: tensor<i1>
func @check_enqueue_ops_update_for_training(%arg0: tensor<?x2xi32>, %arg1: tensor<?x2xi32>,
  %arg2 :tensor<?x2xi32>, %arg3: tensor<?xi32>, %arg4: tensor<?xi32>, %arg5: tensor<?xi32>,
  %arg6: tensor<!tf.string>, %arg7: tensor<!tf.string>, %arg8: tensor<i1>) -> () {
  // CHECK: %[[CONST_0:[a-z0-9]*]] = "tf.Const"()
  %0 = "tf.Const"() {value = dense<[]> : tensor<0xf32>} : () -> tensor<0xf32>
  %1 = "tf.SelectV2"(%arg8, %arg6, %arg7) : (tensor<i1>, tensor<!tf.string>, tensor<!tf.string>) -> tensor<!tf.string>

  %2 = "tf.Const"() {value = dense<0.0> : tensor<2x2xf32>} : () -> tensor<2x2xf32>
  %3 = "tf.Const"() {value = dense<0.0> : tensor<4x4xf32>} : () -> tensor<4x4xf32>
  "tf.SendTPUEmbeddingGradients"(%2, %3) {_tpu_embedding_layer = "call1", config = "\0A\0B\0C\0D", operand_segment_sizes = dense<[2, 0]> : vector<2xi32>} : (tensor<2x2xf32>, tensor<4x4xf32>) -> ()

  // CHECK: "tf.EnqueueTPUEmbeddingSparseTensorBatch"(%[[ARG_0]], %[[ARG_1]], %[[ARG_2]], %[[ARG_3]], %[[ARG_4]], %[[ARG_5]], %[[CONST_0]], %[[CONST_0]], %[[CONST_0]], %[[ARG_6]])
  "tf.EnqueueTPUEmbeddingSparseTensorBatch"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %0, %0, %0, %1) {_tpu_embedding_layer = "call1", _xla_outside_compilation = "0", combiners = ["mean", "sum"], device_ordinal = -1 : i64, max_sequence_lengths = [0, 0, 0], table_ids = [1, 1, 0]} : (tensor<?x2xi32>, tensor<?x2xi32>, tensor<?x2xi32>, tensor<?xi32>, tensor<?xi32>, tensor<?xi32>, tensor<0xf32>, tensor<0xf32>, tensor<0xf32>, tensor<!tf.string>) -> ()
  %4:2 = "tf.RecvTPUEmbeddingActivations"() {_tpu_embedding_layer = "call1", config = "\0A\0B\0C\0D"} : () -> (tensor<2x2xf32>, tensor<4x4xf32>)
  return
}

// -----

func @check_enqueue_ops_with_different_attr_disallowed(%arg0: tensor<?x2xi32>, %arg1: tensor<?x2xi32>,
  %arg2 :tensor<?x2xi32>, %arg3: tensor<?xi32>, %arg4: tensor<?xi32>, %arg5: tensor<?xi32>,
  %arg6: tensor<!tf.string>, %arg7: tensor<!tf.string>, %arg8: tensor<i1>) -> () {
  %0 = "tf.Const"() {value = dense<[]> : tensor<0xf32>} : () -> tensor<0xf32>
  %1 = "tf.SelectV2"(%arg8, %arg6, %arg7) : (tensor<i1>, tensor<!tf.string>, tensor<!tf.string>) -> tensor<!tf.string>
  // expected-error @+1 {{TPU embedding enqueue op must have corresponding RecvTPUEmbeddingActivations op}}
  "tf.EnqueueTPUEmbeddingSparseTensorBatch"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %0, %0, %0, %1) {_tpu_embedding_layer = "call_123", _xla_outside_compilation = "0", combiners = ["mean", "sum"], device_ordinal = -1 : i64, max_sequence_lengths = [0, 0, 0], table_ids = [1, 1, 0]} : (tensor<?x2xi32>, tensor<?x2xi32>, tensor<?x2xi32>, tensor<?xi32>, tensor<?xi32>, tensor<?xi32>, tensor<0xf32>, tensor<0xf32>, tensor<0xf32>, tensor<!tf.string>) -> ()
  %2:2 = "tf.RecvTPUEmbeddingActivations"() {_tpu_embedding_layer = "call1", config = "\0A\0B\0C\0D"} : () -> (tensor<2x2xf32>, tensor<4x4xf32>)
  return
}

// -----

func @check_embedding_ops_with_missing_attribute_disallowed(%arg0: tensor<?x2xi32>, %arg1: tensor<?x2xi32>,
  %arg2 :tensor<?x2xi32>, %arg3: tensor<?xi32>, %arg4: tensor<?xi32>, %arg5: tensor<?xi32>,
  %arg6: tensor<!tf.string>, %arg7: tensor<!tf.string>, %arg8: tensor<i1>) -> () {
  %0 = "tf.Const"() {value = dense<[]> : tensor<0xf32>} : () -> tensor<0xf32>
  %1 = "tf.SelectV2"(%arg8, %arg6, %arg7) : (tensor<i1>, tensor<!tf.string>, tensor<!tf.string>) -> tensor<!tf.string>
  "tf.EnqueueTPUEmbeddingSparseTensorBatch"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %0, %0, %0, %1) {_tpu_embedding_layer = "call_123", _xla_outside_compilation = "0", combiners = ["mean", "sum"], device_ordinal = -1 : i64, max_sequence_lengths = [0, 0, 0], table_ids = [1, 1, 0]} : (tensor<?x2xi32>, tensor<?x2xi32>, tensor<?x2xi32>, tensor<?xi32>, tensor<?xi32>, tensor<?xi32>, tensor<0xf32>, tensor<0xf32>, tensor<0xf32>, tensor<!tf.string>) -> ()
  // expected-error @+1 {{missing required attribute: `_tpu_embedding_layer`}}
  %2:2 = "tf.RecvTPUEmbeddingActivations"() {config = "\0A\0B\0C\0D"} : () -> (tensor<2x2xf32>, tensor<4x4xf32>)
  return
}
