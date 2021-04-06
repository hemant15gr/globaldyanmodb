provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
  version = "~> 2.7"

}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
  version = "~> 2.7"

}



resource "aws_dynamodb_table" "us-east-1" {
  provider = "aws.us-east-1"

  hash_key         = "AnimalType"
  range_key        = "AnimalName"  
  name             = "Animal"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 5
  write_capacity   = 5

  server_side_encryption {                                         #Enable serverside encryption 
   enabled = false

   }
    point_in_time_recovery {                                       #Enable Point in time recovery 
   enabled = true

   }
  attribute {
    name = "AnimalType"
    type = "S"
  }
    attribute {
    name = "AnimalName"
    type = "S"
  }
  attribute {
    name = "Owner"
    type = "S"
  }
  attribute {
    name = "Breed"
    type = "S"
  }

    global_secondary_index {                                          #Gloabl Sencodary index 
    name               = "OwnerIndec"
    hash_key           = "Owner"
    range_key          = "Breed"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }
  lifecycle {
        ignore_changes = ["read_capacity", "write_capacity"]
    }

}


resource "aws_sns_topic" "user_updates_us-east-1_Animal" {             #SNS Topic creation 
  provider = "aws.us-east-1"
  name = "Animal_us-east-1_Alram"
}
###########################
#AutoScalling and Scalling policy for Animal table in us-east-1 region

resource "aws_appautoscaling_target" "Animal_us-east-1_table_read_target" {
  provider = "aws.us-east-1"
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}


resource "aws_appautoscaling_policy" "Animal_us-east-1_table_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_table_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_table_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-east-1_table_write_target" {
  provider = "aws.us-east-1"
  depends_on = ["aws_appautoscaling_target.Animal_us-east-1_table_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"


}

resource "aws_appautoscaling_policy" "Animal_us-east-1_table_write_policy" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_table_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_table_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_table_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}


resource "aws_appautoscaling_target" "Animal_us-east-1_index_read_target" {
  provider = "aws.us-east-1"
  depends_on = ["aws_appautoscaling_target.Animal_us-east-1_table_write_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}

resource "aws_appautoscaling_policy" "Animal_us-east-1_index_read_policy" {
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_index_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_index_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_index_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-east-1_index_write_target" {
  provider = "aws.us-east-1"
  depends_on = ["aws_appautoscaling_target.Animal_us-east-1_index_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace = "dynamodb"


}


resource "aws_appautoscaling_policy" "Animal_us-east-1_index_write_target" {
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-east-1_index_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-east-1_index_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-east-1_index_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}




###################### Animal Table in  us-west-2 region ############

resource "aws_dynamodb_table" "us-west-2" {
  provider = "aws.us-west-2"

  hash_key         = "AnimalType"
  range_key        = "AnimalName"
  name             = "Animal"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  read_capacity    = 5
  write_capacity   = 5

  server_side_encryption {
  enabled = false

  }
    point_in_time_recovery {
   enabled = true

   }

  attribute {
    name = "AnimalType"
    type = "S"
  }
    attribute {
    name = "AnimalName"
    type = "S"
  }
  attribute {
    name = "Owner"
    type = "S"
  }
  attribute {
    name = "Breed"
    type = "S"
  }

    global_secondary_index {
    name               = "OwnerIndec"
    hash_key           = "Owner"
    range_key          = "Breed"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "ALL"
  }

  lifecycle {
        ignore_changes = ["read_capacity", "write_capacity"]
    }

}


####Alram creation for animal table  us-west-2 region


resource "aws_sns_topic" "user_updates_us-west-2_Animal" {             #SNS Topic creation
  provider = "aws.us-west-2"
  name = "Animal_us-west-2_Alram"
}
####Alram creation for animal table us-west-2 region
#AutoScalling and Scalling policy for Animal table in us-west-2 region

resource "aws_appautoscaling_target" "Animal_us-west-2_table_read_target" {
  provider = "aws.us-west-2"
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-west-2.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}


resource "aws_appautoscaling_policy" "Animal_us-west-2_table_read_policy" {
  provider = "aws.us-west-2"
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-east-1_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_table_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_table_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_table_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-west-2_table_write_target" {
  provider = "aws.us-west-2"
  depends_on = ["aws_appautoscaling_target.Animal_us-west-2_table_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-east-1.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"


}

resource "aws_appautoscaling_policy" "Animal_us-west-2_table_write_policy" {
  provider = "aws.us-west-2"
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-west-2_table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_table_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_table_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_table_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}


resource "aws_appautoscaling_target" "Animal_us-west-2_index_read_target" {
  provider = "aws.us-west-2"
  depends_on = ["aws_appautoscaling_target.Animal_us-west-2_table_write_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-west-2.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"

}

resource "aws_appautoscaling_policy" "Animal_us-west-2_index_read_policy" {
  provider = "aws.us-west-2"
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.Animal_us-west-2_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_index_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_index_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_index_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 70
  }
}

resource "aws_appautoscaling_target" "Animal_us-west-2_index_write_target" {
  provider = "aws.us-west-2"
  depends_on = ["aws_appautoscaling_target.Animal_us-west-2_index_read_target"]
  max_capacity       = 100
  min_capacity       = 5
  resource_id        = "table/${aws_dynamodb_table.us-west-2.name}/index/OwnerIndec"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace = "dynamodb"


}


resource "aws_appautoscaling_policy" "Animal_us-west-2_index_write_target" {
  provider = "aws.us-west-2"
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.Animal_us-west-2_table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.Animal_us-west-2_index_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.Animal_us-west-2_index_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.Animal_us-west-2_index_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = 70
  }
}



#Global Table creation

resource "aws_dynamodb_global_table" "Animal" {
  depends_on = ["aws_dynamodb_table.us-east-1", "aws_dynamodb_table.us-west-2"]
  provider   = "aws.us-east-1"


  name = "Animal"

  replica {
    region_name = "us-east-1"
  }

  replica {
    region_name = "us-west-2"
  }


}

