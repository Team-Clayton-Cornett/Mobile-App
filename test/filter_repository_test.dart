import 'package:capstone_app/repositories/filterRepository.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockClock extends Mock implements Clock {}

void main() {
  group('Initialization', () {
    test('Repository is initialized with correct interval', () {
      MockClock clock = MockClock();

      DateTime mockedCurrentDateTime = DateTime.parse('2020-01-06T07:15:00');

      when(clock.now()).thenReturn(mockedCurrentDateTime);

      FilterRepository filterRepo = FilterRepository.getInstance(clock);

      expect(filterRepo.intervalStart, mockedCurrentDateTime);
      expect(filterRepo.intervalEnd, mockedCurrentDateTime.add(Duration(hours: 1)));
    });

    test('Repository is initialized after 11PM', () {
      MockClock clock = MockClock();

      DateTime mockedCurrentDateTime = DateTime.parse('2020-01-06T23:30:00');

      when(clock.now()).thenReturn(mockedCurrentDateTime);

      FilterRepository filterRepo = FilterRepository.getInstance(clock);

      expect(filterRepo.intervalStart, mockedCurrentDateTime);
      expect(filterRepo.intervalEnd, DateTime.parse('2020-01-07T00:00:00'));
    });
  });

  group('Start interval before end interval', () {
    MockClock clock = MockClock();

    DateTime mockedCurrentDateTime = DateTime.parse('2020-01-06T07:15:00');

    when(clock.now()).thenReturn(mockedCurrentDateTime);

    test('Set interval start after interval end', () {
      FilterRepository filterRepo = FilterRepository.getInstance(clock);

      expect(() {
        filterRepo.intervalStart = DateTime.parse('2020-01-06T08:16:00');
      }, throwsAssertionError);
    });

    test('Set interval end before interval start', () {
      FilterRepository filterRepo = FilterRepository.getInstance(clock);

      expect(() {
        filterRepo.intervalEnd = DateTime.parse('2020-01-06T07:14:00');
      }, throwsAssertionError);
    });
  });

  group('Interval rounding', () {
    test('Interval start set along 15 minute boundary', () {
      FilterRepository filterRepo = FilterRepository.getInstance();

      DateTime start = DateTime.parse('2020-01-06T07:30:00');

      filterRepo.intervalStart = start;

      expect(filterRepo.intervalStart, start);
    });

    test('Interval start set not along 15 minute boundary', () {
      FilterRepository filterRepo = FilterRepository.getInstance();

      DateTime start = DateTime.parse('2020-01-06T07:29:30');

      filterRepo.intervalStart = start;

      expect(filterRepo.intervalStart, DateTime.parse('2020-01-06T07:15:00'));
    });

    test('Interval end set along 15 minute boundary', () {
      FilterRepository filterRepo = FilterRepository.getInstance();

      DateTime end = DateTime.parse('2020-01-06T09:30:00');

      filterRepo.intervalEnd = end;

      expect(filterRepo.intervalEnd, end);
    });

    test('Interval end set not along 15 minute boundary', () {
      FilterRepository filterRepo = FilterRepository.getInstance();

      DateTime end = DateTime.parse('2020-01-06T09:29:30');

      filterRepo.intervalEnd = end;

      expect(filterRepo.intervalEnd, DateTime.parse('2020-01-06T09:15:00'));
    });
  });
}